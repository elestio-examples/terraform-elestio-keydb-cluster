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
