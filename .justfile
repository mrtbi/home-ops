#!/usr/bin/env -S just --justfile

set minimum-version := '1.55.0'

set default-list
set default-script
set lazy
set quiet
set script-interpreter := ['bash', '-euo', 'pipefail']
set shell := ['bash', '-euo', 'pipefail', '-c']

mod k8s-bootstrap "kubernetes/bootstrap"
mod k8s "kubernetes"
mod talos "kubernetes/talos"
mod proxmoxtf "terraform/stacks/proxmox"

[private]
default:
    just -l

[private]
log lvl msg *args:
  gum log -t rfc3339 -s -l "{{ lvl }}" "{{ msg }}" {{ args }}

[private]
template-talos file *args:
  infisical run --silent --path /talos --env prod --command "minijinja-cli --autoescape none "{{ file }}" {{ args }}"

[private]
template file *args:
  minijinja-cli --autoescape none "{{ file }}" {{ args }}

[private]
template-bootstrap file:
  infisical run --silent --path /bootstrap --env prod --command "minijinja-cli --env "{{ file }}""