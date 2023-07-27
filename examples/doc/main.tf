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
