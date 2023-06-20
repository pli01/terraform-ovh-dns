# terraform-ovh-dns

Manage OVH DNS record zone

- Describe dns zone and records in a yaml format (default: config.yml)
- terraform plan
- terraform apply

```bash
# Prereq
export OVH_ENDPOINT
export OVH_APPLICATION_KEY
export OVH_APPLICATION_SECRET
export OVH_CONSUMER_KEY

# Optional (store tfstate in gitlab http backend)
export TF_HTTP_USERNAME
export TF_HTTP_PASSWORD
```

```yaml
#
# config.yml syntax
#
domain.com:
  app1:
    fieldtype: "A"
    ttl: 600
    target: "192.168.1.1"
  app2:
    fieldtype: "A"
    ttl: 120
    target: "192.168.2.2"
  app3.test:
    fieldtype: "A"
    ttl: 120
    target: "192.168.2.2"
  #
  # 1 entry app4.$zone with 2 A (round robin)
  #
  app4_first:
    subdomain: app4
    fieldtype: "A"
    ttl: 120
    target: "192.168.1.4"
  app4_second:
    subdomain: app4
    fieldtype: "A"
    ttl: 120
    target: "192.168.1.5"
```

To override default config.yml file
```
# export TF_VAR_config
export TF_VAR_config=myzone.yml
# or with args
terraform -var config=myzone.yml
```
