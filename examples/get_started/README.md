# Example: Get Started with KeyDB Cluster, Terraform and Elestio

In this example you will learn how to use this module to deploy your own KeyDB cluster easily.

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

   It will:

   - Create a new project in your Elestio account
   - Build a KeyDB cluster with the number of nodes you specified

3. You can use the `terraform output` command to print the output block of your main.tf file:

   ```bash
   terraform output nodes_admins # RedisInsight secrets
   terraform output nodes_database_admins # Database secrets
   ```

## Testing

Use `terraform output nodes_admins` command to output RedisInsight secrets:

Log in to both URLs with the credentials.

Create a key/value on the first node.
You should be able to retrieve the value of your key on the second node.

You can try turning off the first node on the [Elestio dashboard](https://dash.elest.io/).
The second node remains functional.
When you restart it, it automatically updates with the new data.

## Scale the nodes

To adjust the cluster size:

- Adding nodes: Run `terraform apply` after adding a new node in the config, and it will be seamlessly integrated into the cluster.
- Removing nodes: The excess nodes will cleanly leave the cluster on the next `terraform apply`.

Please note that changing the node count requires to change the .env of existing nodes. This is done automatically by the module.
