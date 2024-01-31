<!-- BEGIN_TF_DOCS -->
# Elestio KeyDB Cluster Terraform module

## Benefits of a KeyDB cluster

A Multi-Master KeyDB cluster is a great option to ensure high availability, it allows for easy scalability to meet changing demands without replacing the entire system.
It can handle more requests without slowing down or crashing, and provides fault tolerance to ensure that the system remains operational.

A multi-master scenario means that one node can be taken offline (e.g. for maintenance or upgrade purposes) without impacting availability, as the other node will continue to serve production traffic. Further, it doubles your capacity to read or write to the database and provides an additional layer of protection against data loss.

## Module requirements

- 1 Elestio account https://dash.elest.io/signup
- 1 API key https://dash.elest.io/account/security
- 1 SSH public/private key (see how to create one [here](https://registry.terraform.io/providers/elestio/elestio/latest/docs/guides/ssh_keys))

## Module usage

This is a minimal example of how to use the module:

```hcl
module "cluster" {
  source = "elestio-examples/keydb-cluster/elestio"

  project_id = "xxxxxx"
  keydb_pass = "xxxxxx"

  configuration_ssh_key = {
    username    = "something"
    public_key  = chomp(file("~/.ssh/id_rsa.pub"))
    private_key = file("~/.ssh/id_rsa")
  }

  nodes = [
    {
      server_name   = "keydb-1"
      provider_name = "scaleway"
      datacenter    = "fr-par-1"
      server_type   = "SMALL-2C-2G"
    },
    {
      server_name   = "keydb-2"
      provider_name = "scaleway"
      datacenter    = "fr-par-2"
      server_type   = "SMALL-2C-2G"
    },
  ]
}
```

Keep your keydb password safe, you will need it to access the admin panel.

If you want to know more about node configuration, check the keydb service documentation [here](https://registry.terraform.io/providers/elestio/elestio/latest/docs/resources/keydb).

If you want to choose your own provider, datacenter or server type, check the guide [here](https://registry.terraform.io/providers/elestio/elestio/latest/docs/guides/providers_datacenters_server_types).

If you want to generated a valid SSH Key, check the guide [here](https://registry.terraform.io/providers/elestio/elestio/latest/docs/guides/ssh_keys).

If you add more nodes, you may attains the resources limit of your account, please visit your account [quota page](https://dash.elest.io/account/add-quota).

## Quick configuration

The following example will create a KeyDB cluster with 2 nodes.

You may need to adjust the configuration to fit your needs.

Create a `main.tf` file at the root of your project, and fill it with your Elestio credentials:

```hcl
terraform {
  required_providers {
    elestio = {
      source = "elestio/elestio"
    }
  }
}

provider "elestio" {
  email     = "xxxx@xxxx.xxx"
  api_token = "xxxxxxxxxxxxx"
}

resource "elestio_project" "project" {
  name = "KeyDB Cluster"
}
```

Now you can use the module to create keydb nodes:

```hcl
module "cluster" {
  source = "elestio-examples/keydb-cluster/elestio"

  project_id    = elestio_project.project.id
  keydb_version = null # null means latest version
  keydb_pass    = "xxxxxxxxxxxxx"

  configuration_ssh_key = {
    username    = "terraform"
    public_key  = chomp(file("~/.ssh/id_rsa.pub"))
    private_key = file("~/.ssh/id_rsa")
  }

  nodes = [
    {
      server_name   = "keydb-1"
      provider_name = "scaleway"
      datacenter    = "fr-par-1"
      server_type   = "SMALL-2C-2G"
    },
    {
      server_name   = "keydb-2"
      provider_name = "scaleway"
      datacenter    = "fr-par-2"
      server_type   = "SMALL-2C-2G"
    },
  ]
}
```

Finally, let's add some outputs to retrieve useful information:

```hcl
output "nodes_admins" {
  value     = { for node in module.cluster.nodes : node.server_name => node.admin }
  sensitive = true
}

output "nodes_database_admins" {
  value     = { for node in module.cluster.nodes : node.server_name => node.database_admin }
  sensitive = true
}
```

You can now run `terraform init` and `terraform apply` to create your KeyDB cluster.
After a few minutes, the cluster will be ready to use.
You can access your outputs with `terraform output`:

```bash
$ terraform output nodes_admins
$ terraform output nodes_database_admins
```

If you want to update some parameters, you can edit the `main.tf` file and run `terraform apply` again.
Terraform will automatically update the cluster to match the new configuration.
Please note that changing the node count requires to change the .env of existing nodes. This is done automatically by the module.

## Ready-to-deploy example

We created a ready-to-deploy example which creates the same infrastructure as the previous example.
You can find it [here](https://github.com/elestio-examples/terraform-elestio-keydb-cluster/tree/main/examples/get_started).
Follow the instructions to deploy the example.

## How to use the cluster

Use `terraform output nodes_database_admins` command to output database secrets:

```bash
# nodes_database_admins
{
  "keydb-1" = {
    "command" = "redis-cli -h keydb-1-u525.vm.elestio.app -p 23647 -a '*****'"
    "host" = "keydb-1-u525.vm.elestio.app"
    "password" = "*****"
    "port" = "23647"
    "user" = "root"
  }
  "keydb-2" = {
    "command" = "redis-cli -h keydb-2-u525.vm.elestio.app -p 23647 -a '*****'"
    "host" = "keydb-2-u525.vm.elestio.app"
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
  {
    port: 23647,
    password: '****',
    host: 'keydb-1-u525.vm.elestio.app',
  },
  {
    port: 23647,
    password: '****',
    host: 'keydb-2-u525.vm.elestio.app',
  },
]);

cluster.set('foo', 'bar');
cluster.get('foo', (err, res) => {
  // res === 'bar'
});
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_configuration_ssh_key"></a> [configuration\_ssh\_key](#input\_configuration\_ssh\_key) | After the nodes are created, Terraform must connect to apply some custom configuration.<br>This configuration is done using SSH from your local machine.<br>The Public Key will be added to the nodes and the Private Key will be used by your local machine to connect to the nodes.<br><br>Read the guide [\"How generate a valid SSH Key for Elestio\"](https://registry.terraform.io/providers/elestio/elestio/latest/docs/guides/ssh_keys). Example:<pre>configuration_ssh_key = {<br>  username = "admin"<br>  public_key = chomp(file("\~/.ssh/id_rsa.pub"))<br>  private_key = file("\~/.ssh/id_rsa")<br>}</pre> | <pre>object({<br>    username    = string<br>    public_key  = string<br>    private_key = string<br>  })</pre> | n/a | yes |
| <a name="input_keydb_pass"></a> [keydb\_pass](#input\_keydb\_pass) | The password can only contain alphanumeric characters or hyphens `-`.<br>Require at least 10 characters, one uppercase letter, one lowercase letter and one number.<br>Example: `rfxE42snU-bt0y-1KwqweZDq` DO NOT USE **THIS** EXAMPLE PASSWORD. | `string` | n/a | yes |
| <a name="input_keydb_version"></a> [keydb\_version](#input\_keydb\_version) | The cluster nodes must share the same keydb version.<br>Leave empty or set to `null` to use the Elestio recommended version. | `string` | `null` | no |
| <a name="input_nodes"></a> [nodes](#input\_nodes) | Each element of this list will create an Elestio KeyDB Resource in your cluster.<br>Read the following documentation to understand what each attribute does, plus the default values: [Elestio KeyDB Resource](https://registry.terraform.io/providers/elestio/elestio/latest/docs/resources/keydb). | <pre>list(<br>    object({<br>      server_name                                       = string<br>      provider_name                                     = string<br>      datacenter                                        = string<br>      server_type                                       = string<br>      admin_email                                       = optional(string)<br>      alerts_enabled                                    = optional(bool)<br>      app_auto_update_enabled                           = optional(bool)<br>      backups_enabled                                   = optional(bool)<br>      firewall_enabled                                  = optional(bool)<br>      keep_backups_on_delete_enabled                    = optional(bool)<br>      remote_backups_enabled                            = optional(bool)<br>      support_level                                     = optional(string)<br>      system_auto_updates_security_patches_only_enabled = optional(bool)<br>      ssh_public_keys = optional(list(<br>        object({<br>          username = string<br>          key_data = string<br>        })<br>      ), [])<br>    })<br>  )</pre> | `[]` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | n/a | `string` | n/a | yes |
## Modules

No modules.
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_nodes"></a> [nodes](#output\_nodes) | This is the created nodes full information |
## Providers

| Name | Version |
|------|---------|
| <a name="provider_elestio"></a> [elestio](#provider\_elestio) | >= 0.14.0 |
| <a name="provider_null"></a> [null](#provider\_null) | >= 3.2.0 |
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_elestio"></a> [elestio](#requirement\_elestio) | >= 0.14.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.2.0 |
## Resources

| Name | Type |
|------|------|
| [elestio_keydb.nodes](https://registry.terraform.io/providers/elestio/elestio/latest/docs/resources/keydb) | resource |
| [null_resource.update_nodes_env](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
<!-- END_TF_DOCS -->
