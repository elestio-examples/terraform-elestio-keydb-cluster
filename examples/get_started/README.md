# Get started : KeyDB Cluster with Terraform and Elestio

In this example, you will learn how to use this module to deploy your own KeyDB cluster with Elestio.

Some knowledge of [terraform](https://developer.hashicorp.com/terraform/intro) is recommended, but if not, the following instructions are sufficient.

## Prepare the dependencies

- [Sign up for Elestio if you haven't already](https://dash.elest.io/signup)

- [Get your API token in the security settings page of your account](https://dash.elest.io/account/security)

- [Download and install Terraform](https://www.terraform.io/downloads)

  You need a Terraform CLI version equal or higher than v0.14.0.
  To ensure you're using the acceptable version of Terraform you may run the following command: `terraform -v`

## Instructions

1. Rename `secrets.tfvars.example` to `secrets.tfvars` and fill in the values.

   This file contains the sensitive values to be passed as variables to Terraform.</br>
   You should **never commit this file** with git.

2. Run terraform with the following commands:

   ```bash
   terraform init
   terraform plan -var-file="secrets.tfvars" # to preview changes
   terraform apply -var-file="secrets.tfvars"
   terraform show
   ```

3. You can use the `terraform output` command to print the output block of your main.tf file:

   ```bash
   terraform output cluster_admin # RedisInsight secrets
   terraform output cluster_database_admin # Database secrets
   ```

## Testing

Use `terraform output cluster_admin` command to output RedisInsight secrets:

```bash
# cluster_admin
[
  {
    "password" = "****"
    "url" = "https://keydb-0-u525.vm.elestio.app:24814/"
    "user" = "root"
  },
  {
    "password" = "****"
    "url" = "https://keydb-1-u525.vm.elestio.app:24814/"
    "user" = "root"
  },
]
```

Log in to both URLs with the credentials.

Create a key/value on the first node.
You should be able to retrieve the value of your key on the second node.

You can try turning off the first node on the [Elestio dashboard](https://dash.elest.io/).
The second node remains functional.
When you restart it, it automatically updates with the new data.

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

Here is an example of how to use the KeyDB cluster and all its nodes in the [Javascript client](https://opensearch.org/docs/latest/clients/javascript/index/).

```js
// Javascript example
const Redis = require("ioredis");

const cluster = new Redis.Cluster([
  { port: 23647, password: "****", host: "keydb-0-u525.vm.elestio.app" },
  { port: 23647, password: "****", host: "keydb-1-u525.vm.elestio.app" },
]);

cluster.set("foo", "bar");
cluster.get("foo", (err, res) => {
  // res === 'bar'
});
```

## Scale the nodes

To adjust the cluster size:

- Adding nodes: Run `terraform apply` after adding a new node, and it will be seamlessly integrated into the cluster.
- Removing nodes: The excess nodes will cleanly leave the cluster on the next `terraform apply`.

Please note that changing the node count requires a reboot, which may result in a few minutes of service downtime.
