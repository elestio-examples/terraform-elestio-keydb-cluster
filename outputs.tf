output "cluster_nodes" {
  value       = elestio_keydb.nodes
  description = "All the information of the nodes in the cluster"
  sensitive   = true
}

output "cluster_admin" {
  value = [for node in elestio_keydb.nodes : {
    url      = node.admin.url,
    user     = node.admin.user
    password = elestio_keydb.nodes[0].admin.password,
  }]
  description = "The URL and secrets to connect to RedisInsight on each nodes"
  sensitive   = true
}

output "cluster_database_admin" {
  value = [for node in elestio_keydb.nodes : {
    command  = "redis-cli -h ${node.database_admin.host} -p ${node.database_admin.port} -a '${elestio_keydb.nodes[0].admin.password}'",
    host     = node.database_admin.host,
    port     = node.database_admin.port,
    user     = node.database_admin.user
    password = elestio_keydb.nodes[0].admin.password,
  }]
  description = "The database connection string/command for each nodes"
  sensitive   = true
}
