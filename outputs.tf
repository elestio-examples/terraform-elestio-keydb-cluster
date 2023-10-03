output "nodes" {
  description = "This is the created nodes full information"
  value       = elestio_keydb.nodes
  sensitive   = true
}
