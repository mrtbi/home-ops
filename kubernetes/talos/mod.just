set quiet := true
set shell := ['zsh', '-euo', 'pipefail', '-c']

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


[doc('Render Talos config for a node')]
render-config node:
  talosctl machineconfig patch <(just template-talos "{{ talos_dir }}/controlplane.yaml.j2") \
    -p @<(just template-talos "{{ talos_dir }}/nodes/{{ node }}.yaml.j2")

[doc('Generate schematic ID from Talos schematic')]
gen-schematic-id:
  curl -sX POST --data-binary "@{{ talos_dir }}/schematic.yaml" "https://factory.talos.dev/schematics" | jq -r '.id'
