# terraform-ovh-dns

Manage OVH DNS record zone with terraform and OVH


## Use it
- Describe dns zone and records with a configuration file in yaml format (default: `config.yml`)
- Record value: are the same arguments as in the terraform provider : https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/ovh_domain_zone_record
- Run:
```bash
terraform plan
terraform apply
```
- It's done!

## Prereq
- terraform installed
- OVH Credentials and write policy to domain
- (optional: gitlab credentials to store tfstate in gitlab terraform)

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

## Zone configuration file

Describe zone and dns record in a yaml file.

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
  #
  # wildcard (add quotes)
  #
  "*.web":
    fieldtype: "A"
    ttl: 120
    target: "192.168.2.2"
other-domain.com:
  www:
    fieldtype: "A"
    ttl: 600
    target: "192.168.3.1"
```

### Format description

- Zone name: `zone` where to add all records key
  - Record key: (ex app1 )
    - Record value: are the same arguments as in https://registry.terraform.io/providers/ovh/ovh/latest/docs/resources/ovh_domain_zone_record

#### Add simple record
- For example, to add the following dns record in the dns zone:

```
# DNS
app1.domain.com A 192.168.1.1
```

```yaml
# config.yml
domain.com:
  app1: # this is the real dns name =  index name of the terraform ressource
    fieldtype: "A"
    ttl: 120
    target: "192.168.1.1"
```

By default, the record key (ex app1.) = `subdomain` record to add in the zone = the terraform resource index name `ovh_domain_zone_record.zone_record["app1.domain.com"]`


#### Add roundrobin record (multiple A)

- If multiple A record for one record is needed (roundrobin), add `subdomain` key under the record key:

For example, to add the following dns record:
```
# DNS
app4.domain.com A 192.168.1.4
app4.domain.com A 192.168.1.5
```

```yaml
domain.com:
  app4_first: # this is the index name of the terraform ressource
    subdomain: app4 # this is the real dns name of the record
    fieldtype: "A"
    ttl: 120
    target: "192.168.1.4"
  app4_second:
    subdomain: app4 # this is the real dns name of the record
    fieldtype: "A"
    ttl: 120
    target: "192.168.1.5"
```
Result:
  - the record key = `subdomain` record to add in the zone (`app4.domain.com`)
  - the terraform resources index name `ovh_domain_zone_record.zone_record["app4_first.domain.com"]` and `ovh_domain_zone_record.zone_record["app4_second.domain.com"]`

#### Add wildcard record

- To add a wildcard DNS, add double quotes around the record key
```
# DNS
*.web.domain.com A 192.168.1.4
```

```yaml
domain.com:
  #
  # wildcard (add quotes)
  #
  "*.web":
    fieldtype: "A"
    ttl: 120
    target: "192.168.2.2"
```

#### override default config file
- To override default config.yml file

```bash
# export TF_VAR_config
export TF_VAR_config=myzone.yml
# or with args
terraform -var config=myzone.yml
```

#### import DNS record

- get dns record id under ovh api portal
- create your own config file
- To import current DNS zone, add simple quote around the resource, and double quote around the index of the resource

```bash
terraform import 'ovh_domain_zone_record.zone_record["app1.domain.com"]' 1234567890.domain.com
```
