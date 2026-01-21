set positional-arguments := true
set quiet := true
set shell := ['zsh', '-euo', 'pipefail', '-c']

kubernetes_dir := justfile_dir() + '/kubernetes'
talos_dir := kubernetes_dir + '/talos'
controller := `talosctl config info --output json | jq --raw-output '.endpoints[]' | sort -R | head -n 1`
nodes := `talosctl config info -o yaml | yq -e '.nodes | join (",")'`

[private]
default: talos

[doc('Install Talos')]
talos:
  just log info "Running stage..." "stage" "$0"
  for n in {{ nodes }}; do \
    if ! op=$(just talos::apply-node "$n" --insecure 2>&1); then \
      if [[ "$op" == *"certificate required"* ]]; then \
        just log info "Talos already configured, skipping apply of config" "stage" "$0" "node" "$n"; \
        continue; \
      fi; \
    fi; \
    just log info "Nothing to do..." "stage" "$0"; \
  done