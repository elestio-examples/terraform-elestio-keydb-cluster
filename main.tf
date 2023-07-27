resource "elestio_keydb" "nodes" {
  for_each = { for value in var.nodes : value.server_name => value }

  project_id       = var.project_id
  version          = var.keydb_version
  server_name      = each.value.server_name
  default_password = var.keydb_admin_password
  provider_name    = each.value.provider_name
  datacenter       = each.value.datacenter
  server_type      = each.value.server_type
  support_level    = each.value.support_level
  admin_email      = each.value.admin_email
  ssh_keys         = concat(each.value.ssh_keys, [var.ssh_key])

  connection {
    type        = "ssh"
    host        = self.ipv4
    private_key = var.ssh_key.private_key
  }

  provisioner "remote-exec" {
    inline = [
      "cd /opt/app",
      "docker-compose down",
      "rm -rf insight",
      "mkdir -p insight",
      "chmod -R 777 insight",
      "docker-compose up -d",
      "sleep 15",
      "curl --header \"Content-Type: application/json\" --request POST --data '{ \"name\": \"localRedis\", \"connectionType\": \"STANDALONE\", \"host\": \"172.17.0.1\",\"port\": 23647,\"password\": \"${var.keydb_admin_password}\"}' http://172.17.0.1:8001/api/instance/",
    ]
  }
}

# The .env file contains some variables that change depending on the number of nodes
# Triggering this resource when the number of nodes changes allows us to update the .env file
# of each nodes and restart the docker-compose
resource "null_resource" "update_nodes_env" {
  for_each = { for node in elestio_keydb.nodes : node.server_name => node }

  triggers = {
    cluster_nodes_ids = join(",", [for node in elestio_keydb.nodes : node.id])
  }

  connection {
    type        = "ssh"
    host        = each.value.ipv4
    private_key = var.ssh_key.private_key
  }

  provisioner "remote-exec" {
    inline = [
      "cd /opt/app",
      "sed -i \"/CLUSTER_OPTIONS=/c\\CLUSTER_OPTIONS=--masterauth ${var.keydb_admin_password} --multi-master yes --active-replica yes ${join(" ", [for node in elestio_keydb.nodes : format("--replicaof %s %s", node.global_ip, node.database_admin.port) if node.server_name != each.value.server_name])}\" .env",
      "docker-compose up -d",
    ]
  }
}
