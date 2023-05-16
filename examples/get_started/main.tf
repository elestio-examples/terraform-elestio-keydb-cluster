terraform {
  required_providers {
    elestio = {
      source = "elestio/elestio"
    }
  }
}

provider "elestio" {
  email     = var.elestio_email
  api_token = var.elestio_api_token
}

resource "elestio_project" "project" {
  name             = "KeyDB Cluster"
  description      = "Ready-to-deploy terraform example"
  technical_emails = var.elestio_email
}

module "cluster" {
  # source = "elestio-examples/keydb-cluster/elestio"
  source = "../.." # If you want to use the local version

  project_id  = elestio_project.project.id
  server_name = "keydb"
  admin_email = var.elestio_email

  # Read the documentation to see the full providers/datacenters/server_types list:
  # https://registry.terraform.io/providers/elestio/elestio/latest/docs/guides/3_providers_datacenters_server_types
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
  ]

  ssh_key = {
    key_name    = "admin"                   # or var.ssh_key.name
    public_key  = file("~/.ssh/id_rsa.pub") # or var.ssh_key.public_key
    private_key = file("~/.ssh/id_rsa")     # or var.ssh_key.private_key
    # See variables.tf and secrets.tfvars file comments if your want to use variables instead of file() function.
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
