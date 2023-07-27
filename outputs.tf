output "keydb_nodes" {
  value       = elestio_keydb.nodes
  description = "List of nodes of the Keydb cluster"
}

output "keydb_admin" {
  value       = { for node in elestio_keydb.nodes : node.server_name => node.admin }
  description = "The URL and secrets to connect to RedisInsight on each nodes"
  sensitive   = true
}

output "keydb_database_admin" {
  value = { for node in elestio_keydb.nodes : node.server_name => node.database_admin }
  # value = [for node in elestio_keydb.nodes : {
  #   command  = "redis-cli -h ${node.database_admin.host} -p ${node.database_admin.port} -a '${elestio_keydb.nodes[0].admin.password}'",
  #   host     = node.database_admin.host,
  #   port     = node.database_admin.port,
  #   user     = node.database_admin.user
  #   password = elestio_keydb.nodes[0].admin.password,
  # }]
  description = "The database connection string/command for each nodes"
  sensitive   = true
}
