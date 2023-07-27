variable "project_id" {
  type        = string
  nullable    = false
  description = <<-EOF
    Related [documentation](https://registry.terraform.io/providers/elestio/elestio/latest/docs/resources/keydb#project_id) `#project_id`
  EOF
}

variable "keydb_version" {
  type        = string
  nullable    = true
  default     = null
  description = <<-EOF
    KeyDB version to use.
    Leave empty or set to `null` to use the Elestio recommended version.
    More information about the `version` can be found in the Elestio [documentation](https://registry.terraform.io/providers/elestio/elestio/latest/docs/resources/keydb#version).
  EOF
}

variable "keydb_admin_password" {
  type        = string
  nullable    = false
  sensitive   = true
  description = <<-EOF
    Keydb authentication password.
    The password can only contain alphanumeric characters or hyphens `-`.
    Require at least 10 characters, one uppercase letter, one lowercase letter and one number.
  EOF
  validation {
    condition     = length(var.keydb_admin_password) >= 10
    error_message = "The password must be at least 10 characters long."
  }
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.keydb_admin_password))
    error_message = "The password can only contain alphanumeric characters or hyphens `-`."
  }
  validation {
    condition     = can(regex("[A-Z]", var.keydb_admin_password))
    error_message = "The password must contain at least one uppercase letter."
  }
  validation {
    condition     = can(regex("[a-z]", var.keydb_admin_password))
    error_message = "The password must contain at least one lowercase letter."
  }
  validation {
    condition     = can(regex("[0-9]", var.keydb_admin_password))
    error_message = "The password must contain at least one number."
  }
}

variable "nodes" {
  type = list(
    object({
      server_name   = string
      provider_name = string
      datacenter    = string
      server_type   = string
      support_level = optional(string, "level1")
      admin_email   = optional(string)
      ssh_keys = optional(list(
        object({
          key_name   = string
          public_key = string
        })
      ), [])
    })
  )
  nullable    = false
  description = <<-EOF
    - `server_name`: Each resource must have a unique name within the project.

    - `provider_name`, `datacenter`, `server_type`: [documentation](https://registry.terraform.io/providers/elestio/elestio/latest/docs/guides/3_providers_datacenters_server_types).

    - `support_level`: `level1`, `level2` or `level3` [documentation](https://registry.terraform.io/providers/elestio/elestio/latest/docs/resources/keydb#support_level).

    - `admin_email`: Email address of the administrator that will receive information about the node.

    - `ssh_keys`: List of SSH keys that will be added to the node. [documentation](https://registry.terraform.io/providers/elestio/elestio/latest/docs/resources/keydb#ssh_keys).
  EOF

  validation {
    condition     = length(var.nodes) > 0
    error_message = "You must provide in at least one node configuration."
  }
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
    This module requires Terraform to connect to the nodes to configure them.
    This SSH key will be added to all nodes configuration.
  EOF
}
