resource "elestio_keydb" "nodes" {
  for_each = { for value in var.nodes : value.server_name => value }

  project_id       = var.project_id
  version          = var.keydb_version
  default_password = var.keydb_pass
  server_name      = each.value.server_name
  provider_name    = each.value.provider_name
  datacenter       = each.value.datacenter
  server_type      = each.value.server_type
  // Merge the module configuration_ssh_key with the optional ssh_public_keys attribute
  ssh_public_keys = concat(each.value.ssh_public_keys, [{
    username = var.configuration_ssh_key.username
    key_data = var.configuration_ssh_key.public_key
  }])

  // Optional attributes
  admin_email                                       = each.value.admin_email
  alerts_enabled                                    = each.value.alerts_enabled
  app_auto_updates_enabled                          = each.value.app_auto_update_enabled
  backups_enabled                                   = each.value.backups_enabled
  firewall_enabled                                  = each.value.firewall_enabled
  keep_backups_on_delete_enabled                    = each.value.keep_backups_on_delete_enabled
  remote_backups_enabled                            = each.value.remote_backups_enabled
  support_level                                     = each.value.support_level
  system_auto_updates_security_patches_only_enabled = each.value.system_auto_updates_security_patches_only_enabled

  connection {
    type        = "ssh"
    host        = self.ipv4
    private_key = var.configuration_ssh_key.private_key
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
      "curl --header \"Content-Type: application/json\" --request POST --data '{ \"name\": \"localRedis\", \"connectionType\": \"STANDALONE\", \"host\": \"172.17.0.1\",\"port\": 23647,\"password\": \"${var.keydb_pass}\"}' http://172.17.0.1:8001/api/instance/",
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
    private_key = var.configuration_ssh_key.private_key
  }

  provisioner "remote-exec" {
    inline = [
      "cd /opt/app",
      "sed -i \"/CLUSTER_OPTIONS=/c\\CLUSTER_OPTIONS=--masterauth ${var.keydb_pass} --multi-master yes --active-replica yes ${join(" ", [for node in elestio_keydb.nodes : format("--replicaof %s %s", node.global_ip, node.database_admin.port) if node.server_name != each.value.server_name])}\" .env",
      "docker-compose up -d",
    ]
  }
}
