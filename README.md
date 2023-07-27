<!-- BEGIN_TF_DOCS -->
# Elestio KeyDB Cluster Terraform module

## Benefits of a KeyDB cluster

A Multi-Master KeyDB cluster is a great option to ensure high availability, it allows for easy scalability to meet changing demands without replacing the entire system.
It can handle more requests without slowing down or crashing, and provides fault tolerance to ensure that the system remains operational.

A multi-master scenario means that one node can be taken offline (e.g. for maintenance or upgrade purposes) without impacting availability, as the other node will continue to serve production traffic. Further, it doubles your capacity to read or write to the database and provides an additional layer of protection against data loss.



## Usage

```hcl
module "keydb_cluster" {
  source = "elestio-examples/keydb-cluster/elestio"

  project_id           = "1234"
  keydb_admin_password = var.keydb_password
  ssh_key = {
    key_name    = var.ssh_key_name
    public_key  = var.ssh_public_key
    private_key = var.ssh_private_key
  }
  nodes = [
    {
      server_name   = "keycloak-france"
      provider_name = "scaleway"
      datacenter    = "fr-par-1"
      server_type   = "SMALL-2C-2G"
    },
    {
      server_name   = "keycloak-netherlands"
      provider_name = "scaleway"
      datacenter    = "nl-ams-1"
      server_type   = "SMALL-2C-2G"
    },
    # You can add more nodes here, but you need to have enough resources quota
    # You can see and udpdate your resources quota on https://dash.elest.io/account/add-quota
  ]
}

output "keydb_cluster_admin" {
  value       = module.keydb_cluster.keydb_admin
  sensitive   = true
  description = "RedisInsight (Redis GUI compatible with KeyDB) connection infos/secrets"
}

output "keydb_cluster_database_admin" {
  value       = module.keydb_cluster.keydb_database_admin
  sensitive   = true
  description = "Database connection infos/secrets"
}
```

## What the module does

1. It configures the KeyDB nodes to be clustered together.

2. If you change the number of nodes and re-apply, it will automatically reconfigure the cluster for you without data-loss.

## Examples

- [Get Started](https://github.com/elestio-examples/terraform-elestio-keydb-cluster/tree/main/examples/get_started) - Ready-to-deploy example which creates a KeyDB Cluster in minutes.

## How to use Multi-Master cluster

Use `terraform output keydb_cluster_database_admin` command to output database secrets:

```bash
# keydb_cluster_database_admin
{
  "keydb-france" = {
    "command" = "redis-cli -h keydb-france-u525.vm.elestio.app -p 23647 -a '*****'"
    "host" = "keydb-france-u525.vm.elestio.app"
    "password" = "*****"
    "port" = "23647"
    "user" = "root"
  }
  "keydb-netherlands" = {
    "command" = "redis-cli -h keydb-netherlands-u525.vm.elestio.app -p 23647 -a '*****'"
    "host" = "keydb-netherlands-u525.vm.elestio.app"
    "password" = "*****"
    "port" = "23647"
    "user" = "root"
  }
}
```

Here is an example of how to use the KeyDB cluster and all its nodes in the Javascript client.

```js
// Javascript example
const Redis = require('ioredis');

const cluster = new Redis.Cluster([
  { port: 23647, password: '****', host: 'keydb-france-u525.vm.elestio.app' },
  {
    port: 23647,
    password: '****',
    host: 'keydb-netherlands-u525.vm.elestio.app',
  },
]);

cluster.set('foo', 'bar');
cluster.get('foo', (err, res) => {
  // res === 'bar'
});
```

## Scale the nodes

To adjust the cluster size:

- Adding nodes: Run `terraform apply` after adding a new node in the config, and it will be seamlessly integrated into the cluster.
- Removing nodes: The excess nodes will cleanly leave the cluster on the next `terraform apply`.

Please note that changing the node count requires to change the .env of existing nodes. This is done automatically by the module.


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_keydb_admin_password"></a> [keydb\_admin\_password](#input\_keydb\_admin\_password) | Keydb authentication password.<br>The password can only contain alphanumeric characters or hyphens `-`.<br>Require at least 10 characters, one uppercase letter, one lowercase letter and one number. | `string` | n/a | yes |
| <a name="input_keydb_version"></a> [keydb\_version](#input\_keydb\_version) | KeyDB version to use.<br>Leave empty or set to `null` to use the Elestio recommended version.<br>More information about the `version` can be found in the Elestio [documentation](https://registry.terraform.io/providers/elestio/elestio/latest/docs/resources/keydb#version). | `string` | `null` | no |
| <a name="input_nodes"></a> [nodes](#input\_nodes) | - `server_name`: Each resource must have a unique name within the project.<br><br>- `provider_name`, `datacenter`, `server_type`: [documentation](https://registry.terraform.io/providers/elestio/elestio/latest/docs/guides/3_providers_datacenters_server_types).<br><br>- `support_level`: `level1`, `level2` or `level3` [documentation](https://registry.terraform.io/providers/elestio/elestio/latest/docs/resources/keydb#support_level).<br><br>- `admin_email`: Email address of the administrator that will receive information about the node.<br><br>- `ssh_keys`: List of SSH keys that will be added to the node. [documentation](https://registry.terraform.io/providers/elestio/elestio/latest/docs/resources/keydb#ssh_keys). | <pre>list(<br>    object({<br>      server_name   = string<br>      provider_name = string<br>      datacenter    = string<br>      server_type   = string<br>      support_level = optional(string, "level1")<br>      admin_email   = optional(string)<br>      ssh_keys = optional(list(<br>        object({<br>          key_name   = string<br>          public_key = string<br>        })<br>      ), [])<br>    })<br>  )</pre> | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Related [documentation](https://registry.terraform.io/providers/elestio/elestio/latest/docs/resources/keydb#project_id) `#project_id` | `string` | n/a | yes |
| <a name="input_ssh_key"></a> [ssh\_key](#input\_ssh\_key) | This module requires Terraform to connect to the nodes to configure them.<br>This SSH key will be added to all nodes configuration. | <pre>object({<br>    key_name    = string<br>    public_key  = string<br>    private_key = string<br>  })</pre> | n/a | yes |
## Modules

No modules.
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_keydb_admin"></a> [keydb\_admin](#output\_keydb\_admin) | The URL and secrets to connect to RedisInsight on each nodes |
| <a name="output_keydb_database_admin"></a> [keydb\_database\_admin](#output\_keydb\_database\_admin) | The database connection string/command for each nodes |
| <a name="output_keydb_nodes"></a> [keydb\_nodes](#output\_keydb\_nodes) | List of nodes of the Keydb cluster |
## Providers

| Name | Version |
|------|---------|
| <a name="provider_elestio"></a> [elestio](#provider\_elestio) | >= 0.10.2 |
| <a name="provider_null"></a> [null](#provider\_null) | >= 3.2.0 |
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_elestio"></a> [elestio](#requirement\_elestio) | >= 0.10.2 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.2.0 |
## Resources

| Name | Type |
|------|------|
| [elestio_keydb.nodes](https://registry.terraform.io/providers/elestio/elestio/latest/docs/resources/keydb) | resource |
| [null_resource.update_nodes_env](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
<!-- END_TF_DOCS -->
