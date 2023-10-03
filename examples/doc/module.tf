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
