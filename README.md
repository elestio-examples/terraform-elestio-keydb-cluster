<!-- BEGIN_TF_DOCS -->
# Elestio KeyDB Cluster Terraform module

If you can't afford for your database to be down for even a few minutes, a Multi-Master cluster is a great option to ensure high availability.

A multi-master scenario means that one node can be taken offline (e.g. for maintenance or upgrade purposes) without impacting availability, as the other node will continue to serve production traffic. Further, it doubles your capacity to read or write to the database and provides an additional layer of protection against data loss.



This module deploy multiple KeyDB nodes on Elestio and commands are automatically executed to link them using the multi-master feature.

## Usage

There is a [ready-to-deploy example](https://github.com/elestio-examples/terraform-elestio-keydb-cluster/tree/main/examples/get_started) included in the [examples](https://github.com/elestio-examples/terraform-elestio-keydb-cluster/tree/main/examples) folder but simple usage is as follows:

```hcl
# Read the module documentation if you need information about a field below

module "cluster" {
  source = "elestio-examples/keydb-cluster/elestio"

  project_id    = "1234"
  server_name   = "keydb"
  keydb_version = null # keep `null` for recommended Elestio version
  support_level = "level1"
  admin_email   = "admin@example.com"
  nodes = [
    {
      provider_name = "hetzner"
      datacenter    = "fsn1" # germany
      server_type   = "SMALL-1C-2G"
    },
    {
      provider_name = "hetzner"
      datacenter    = "hel1" # finlande
      server_type   = "SMALL-1C-2G"
    },
    # You can add more nodes below if you need
  ]
  ssh_key = {
    key_name    = "admin"
    public_key  = file("~/.ssh/id_rsa.pub")
    private_key = file("~/.ssh/id_rsa")
  }
}

output "cluster_admin" {
  value       = module.cluster.cluster_admin
  sensitive   = true
  description = "RedisInsight (Redis GUI compatible with KeyDB) connection infos/secrets"
}

output "cluster_database_admin" {
  value       = module.cluster.cluster_database_admin
  sensitive   = true
  description = "Database connection infos/secrets"
}
```

## Examples

- [Get Started](https://github.com/elestio-examples/terraform-elestio-keydb-cluster/tree/main/examples/get_started) - Ready-to-deploy example which creates KeyDB Cluster on Elestio with Terraform in 5 minutes.


## How to use Multi-Master cluster

Use `terraform output cluster_database_admin` command to output database secrets:

```bash
# cluster_database_admin
[
{
"command" = "redis-cli -h keydb-0-u525.vm.elestio.app -p 23647 -a '****'"
"host" = "keydb-0-u525.vm.elestio.app"
"password" = "****"
"port" = "23647"
"user" = "root"
},
{
"command" = "redis-cli -h keydb-1-u525.vm.elestio.app -p 23647 -a '****'"
"host" = "keydb-1-u525.vm.elestio.app"
"password" = "****"
"port" = "23647"
"user" = "root"
},
]
```

```js
////////////// NodeJS sample //////////////
const Redis = require("ioredis");
const cluster = new Redis.Cluster([
{ port: 23647, password: "****", host: "keydb-0-u525.vm.elestio.app" },
{ port: 23647, password: "****", host: "keydb-1-u525.vm.elestio.app" },
]);

cluster.set("foo", "bar");
cluster.get("foo", (err, res) => {
// res === 'bar'
});
////////////// ////////////// ////////////// //////////////
```


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_email"></a> [admin\_email](#input\_admin\_email) | Related [documentation](https://registry.terraform.io/providers/elestio/elestio/latest/docs/resources/keydb#admin_email) `#admin_email` | `string` | n/a | yes |
| <a name="input_keydb_version"></a> [keydb\_version](#input\_keydb\_version) | Related [documentation](https://registry.terraform.io/providers/elestio/elestio/latest/docs/resources/keydb#version) `#version` | `string` | n/a | yes |
| <a name="input_nodes"></a> [nodes](#input\_nodes) | See [providers list](https://registry.terraform.io/providers/elestio/elestio/latest/docs/guides/3_providers_datacenters_server_types) | <pre>list(<br>    object({<br>      provider_name = string<br>      datacenter    = string<br>      server_type   = string<br>    })<br>  )</pre> | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Related [documentation](https://registry.terraform.io/providers/elestio/elestio/latest/docs/resources/keydb#project_id) `#project_id` | `string` | n/a | yes |
| <a name="input_server_name"></a> [server\_name](#input\_server\_name) | Related [documentation](https://registry.terraform.io/providers/elestio/elestio/latest/docs/resources/keydb#server_name) `#server_name` | `string` | n/a | yes |
| <a name="input_ssh_key"></a> [ssh\_key](#input\_ssh\_key) | A local SSH connection is required to run the commands on all nodes to create the cluster. | <pre>object({<br>    key_name    = string<br>    public_key  = string<br>    private_key = string<br>  })</pre> | n/a | yes |
| <a name="input_support_level"></a> [support\_level](#input\_support\_level) | Related [documentation](https://registry.terraform.io/providers/elestio/elestio/latest/docs/resources/keydb#support_level) `#support_level` | `string` | n/a | yes |
## Modules

No modules.
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_admin"></a> [cluster\_admin](#output\_cluster\_admin) | The URL and secrets to connect to RedisInsight on each nodes |
| <a name="output_cluster_database_admin"></a> [cluster\_database\_admin](#output\_cluster\_database\_admin) | The database connection string/command for each nodes |
| <a name="output_cluster_nodes"></a> [cluster\_nodes](#output\_cluster\_nodes) | All the information of the nodes in the cluster |
## Providers

| Name | Version |
|------|---------|
| <a name="provider_elestio"></a> [elestio](#provider\_elestio) | >= 0.7.1 |
| <a name="provider_null"></a> [null](#provider\_null) | >= 3.2.0 |
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_elestio"></a> [elestio](#requirement\_elestio) | >= 0.7.1 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.2.0 |
## Resources

| Name | Type |
|------|------|
| [elestio_keydb.nodes](https://registry.terraform.io/providers/elestio/elestio/latest/docs/resources/keydb) | resource |
| [null_resource.cluster_configuration](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
<!-- END_TF_DOCS -->
