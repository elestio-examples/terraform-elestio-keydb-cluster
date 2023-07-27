terraform {
  required_version = ">= 0.13"
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
  technical_emails = var.elestio_email
}

module "keydb_cluster" {
  source = "elestio-examples/keydb-cluster/elestio"
  # source = "../.." # Use this line to test the module locally

  project_id           = elestio_project.project.id
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
