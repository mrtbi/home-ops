set default-list
set default-script
set quiet
set script-interpreter := ['bash', '-euo', 'pipefail']
set shell := ['bash', '-euo', 'pipefail', '-c']

kubernetes_dir := justfile_dir() + '/kubernetes'
talos_dir := kubernetes_dir + '/talos'
controller := `talosctl config info --output json | jq --raw-output '.endpoints[]' | sort -R | head -n 1`
nodes := `talosctl config info -o yaml | yq -e '.nodes | join (",")'`

[private]
default:
  just -l talos

[doc('Apply Talos config to a node')]
apply-node node *args:
  #just log info "Applying Talos machineconfig" "node" "{{ node }}";
  just talos render-config "{{ node }}" | talosctl -n "{{ node }}" apply-config -f /dev/stdin {{ args }}

[doc('Access a nodes dashboard')]
dashboard node:
  talosctl -n {{ node }} dashboard

[doc('Upgrade Kubernetes version on the cluster')]
upgrade-k8s version *args:
    talosctl -n {{ controller }} upgrade-k8s --to {{ version }} {{ args }}

[confirm('Upgrade node ' + node + ' [y|N] ?')]
[doc('Upgrade Talos version on a node')]
upgrade-node node *args:
    talosctl -n "{{ node }}" upgrade -i "$(just talos machine-image "{{ node }}")" -m powercycle --timeout=10m {{ args }}

[doc('Render Talos config for a node')]
render-config node:
    export SCHEMATIC="$(just talos schematic-id "{{ node }}")"
    export TALOS_VERSION="$(just talos talos-version)"
    export K8S_VERSION="$(just talos k8s-version)"
    role="controlplane"
    if [[ -f "{{ source_directory() }}/nodes/worker/{{ node }}.yaml.j2" ]]; then
        role="worker"
    fi
    talosctl machineconfig patch <(just template-talos "{{ source_directory() }}/cluster.yaml.j2" -D "schematic=${SCHEMATIC}" -D "talos_version=${TALOS_VERSION}" -D "k8s_version=${K8S_VERSION}") \
        -p @<(just template-talos "{{ source_directory() }}/${role}.yaml.j2" -D "talos_version=${TALOS_VERSION}" -D "k8s_version=${K8S_VERSION}") \
        -p @<(just template-talos "{{ source_directory() }}/nodes/${role}/{{ node }}.yaml.j2" -D "schematic=${SCHEMATIC}" -D "talos_version=${TALOS_VERSION}")


[doc('Generate schematic ID from Talos schematic')]
gen-schematic-id:
  curl -sX POST --data-binary "@{{ talos_dir }}/schematic.yaml" "https://factory.talos.dev/schematics" | jq -r '.id'

[doc('Fetch Talos version from configuration')]
talos-version:
    yq eval '.talos_version' "{{ source_directory() }}/version.yaml"

[doc('Fetch Kubernetes version from configuration')]
[private]
k8s-version:
    yq eval '.k8s_version' "{{ source_directory() }}/version.yaml"

[private]
schematic-file node="":
    file="{{ source_directory() }}/schematic.yaml"
    if [[ -n "{{ node }}" ]]; then
      for f in "{{ source_directory() }}"/nodes/*/"{{ node }}".schematic.yaml; do
        [[ -f "$f" ]] && file="$f"
      done
    fi
    echo "$file"

schematic-id node="":
    curl -sX POST --data-binary @<(just template "$(just talos schematic-file "{{ node }}")") "https://factory.talos.dev/schematics" | jq -r '.id'

machine-image node="":
    export NODE="{{ node }}"
    if [[ -z "${NODE}" ]]; then
        NODE="$(talosctl config info -o yaml | yq -r -e '.nodes[0]')"
    fi
    just talos render-config delta.k8s.internal | yq -r -e 'select(.machine) | .machine.install.image'