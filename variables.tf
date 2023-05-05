variable "project_id" {
  type        = string
  nullable    = false
  description = <<-EOF
    Related [documentation](https://registry.terraform.io/providers/elestio/elestio/latest/docs/resources/keydb#project_id) `#project_id`
  EOF
}

variable "server_name" {
  type        = string
  nullable    = false
  description = <<-EOF
    Related [documentation](https://registry.terraform.io/providers/elestio/elestio/latest/docs/resources/keydb#server_name) `#server_name`
  EOF
}

variable "nodes" {
  type = list(
    object({
      provider_name = string
      datacenter    = string
      server_type   = string
    })
  )
  nullable    = false
  description = <<-EOF
    See [providers list](https://registry.terraform.io/providers/elestio/elestio/latest/docs/guides/3_providers_datacenters_server_types)
  EOF

  validation {
    condition     = length(var.nodes) > 1
    error_message = "You must fill in at least two nodes."
  }
}

variable "keydb_version" {
  type        = string
  nullable    = true
  description = <<-EOF
    Related [documentation](https://registry.terraform.io/providers/elestio/elestio/latest/docs/resources/keydb#version) `#version`
  EOF
}

variable "support_level" {
  type        = string
  nullable    = false
  description = <<-EOF
    Related [documentation](https://registry.terraform.io/providers/elestio/elestio/latest/docs/resources/keydb#support_level) `#support_level`
  EOF
}

variable "admin_email" {
  type        = string
  nullable    = false
  description = <<-EOF
    Related [documentation](https://registry.terraform.io/providers/elestio/elestio/latest/docs/resources/keydb#admin_email) `#admin_email`
  EOF
}

variable "ssh_key" {
  type = object({
    key_name    = string
    public_key  = string
    private_key = string
  })
  nullable    = false
  sensitive   = true
  description = <<-EOF
    A local SSH connection is required to run the commands on all nodes to create the cluster.
  EOF
}
