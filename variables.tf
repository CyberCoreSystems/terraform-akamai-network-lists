variable "network_lists" {
  description = <<-EOT
    Network lists to manage, keyed by a stable identifier. Each entry produces one
    akamai_networklist_network_list. type is IP (IP/CIDR entries, 50k limit) or GEO
    (two-letter country / region codes, 275 limit). mode controls how `entries`
    reconcile against the list contents: REPLACE makes Terraform fully own the list
    (recommended — declarative, deny-by-default), APPEND only adds, REMOVE only
    deletes. Provide contract_id/group_id per list or inherit the module defaults.
  EOT
  type = map(object({
    name        = string
    type        = string
    description = optional(string, "Managed by Terraform (IaC Bazaar).")
    mode        = optional(string, "REPLACE")
    entries     = optional(list(string), [])
    contract_id = optional(string)
    group_id    = optional(string)
  }))

  validation {
    condition     = length(var.network_lists) > 0
    error_message = "Provide at least one network list."
  }

  validation {
    condition     = alltrue([for nl in values(var.network_lists) : contains(["IP", "GEO"], upper(nl.type))])
    error_message = "Each network list type must be IP or GEO."
  }

  validation {
    condition     = alltrue([for nl in values(var.network_lists) : contains(["APPEND", "REPLACE", "REMOVE"], upper(nl.mode))])
    error_message = "Each network list mode must be APPEND, REPLACE, or REMOVE."
  }

  validation {
    condition     = alltrue([for nl in values(var.network_lists) : length(nl.name) > 0])
    error_message = "Every network list needs a non-empty name."
  }
}

variable "contract_id" {
  description = "Default Akamai contract ID for lists that do not set their own (with or without the ctr_ prefix). Optional; the API can infer it for some accounts."
  type        = string
  default     = null
}

variable "group_id" {
  description = "Default Akamai group ID for lists that do not set their own (with or without the grp_ prefix). Optional; the API can infer it for some accounts."
  type        = string
  default     = null
}

variable "activate" {
  description = "Activate each managed list after changes. Off by default so the first apply only stages list contents; flip on (with notification_emails) to push live."
  type        = bool
  default     = false
}

variable "activation_network" {
  description = "Network the activation targets: STAGING (safe default) or PRODUCTION."
  type        = string
  default     = "STAGING"

  validation {
    condition     = contains(["STAGING", "PRODUCTION"], upper(var.activation_network))
    error_message = "activation_network must be STAGING or PRODUCTION."
  }
}

variable "activation_notes" {
  description = "Note recorded on each activation."
  type        = string
  default     = "Activated by Terraform (IaC Bazaar)."
}

variable "notification_emails" {
  description = "Email addresses notified about activation progress. Required when activate = true."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for email in var.notification_emails : can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", email))])
    error_message = "notification_emails must be valid email addresses."
  }
}
