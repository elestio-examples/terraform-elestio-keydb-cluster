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
  name = "keydb-cluster"
}

module "cluster" {
  source = "elestio-examples/keydb-cluster/elestio"

  project_id    = elestio_project.project.id
  keydb_version = null # null means latest version
  keydb_pass    = var.keydb_pass

  configuration_ssh_key = {
    username    = "admin"
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

output "nodes_admins" {
  value     = { for node in module.cluster.nodes : node.server_name => node.admin }
  sensitive = true
}

output "nodes_database_admins" {
  value     = { for node in module.cluster.nodes : node.server_name => node.database_admin }
  sensitive = true
}
