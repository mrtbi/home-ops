set quiet := true
set shell := ['bash', '-euo', 'pipefail', '-c']

kubernetes_dir := justfile_dir() + '/kubernetes'

[private]
default:
  just -l k8s

[doc('Open a shell on a node')]
node-shell node:
  kubectl debug node/{{ node }} -n default -it --image='mirror.gcr.io/alpine:latest' --profile sysadmin
  kubectl delete pod -n default -l app.kubernetes.io/managed-by=kubectl-debug

[doc('Prune pods in Failed, Pending, or Succeeded state')]
prune-pods:
  for phase in Failed Pending Succeeded; do \
    kubectl delete pods -A --field-selector status.phase="$phase" --ignore-not-found=true; \
  done