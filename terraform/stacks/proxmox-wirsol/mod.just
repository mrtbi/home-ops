[private]
default:
    just -l

[doc('Run tofu init')]
init *args:
    infisical run --silent --path /proxmox --env prod --command "tofu init {{ args }}"

[doc('Run tofu plan')]
plan *args:
    infisical run --silent --path /proxmox --env prod --command "tofu plan {{ args }}"

[doc('Run tofu apply')]
apply *args:
    infisical run --silent --path /proxmox --env prod --command "tofu apply {{ args }}"

[doc('Run tofu destroy')]
destroy *args:
    infisical run --silent --path /proxmox --env prod --command "tofu destroy {{ args }}"
