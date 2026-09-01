# Versioned Akamai Network Lists (IP/CIDR and GEO) with optional activation.
# These lists feed App & API Protector IP/geo firewalls and delivery-property
# rules. Secure posture: lists default to REPLACE mode so Terraform fully owns
# the contents (no drift), and activation is opt-in to STAGING first. Works with
# Terraform and OpenTofu.

locals {
  # Normalize per-list type/mode to the upper-case values the API expects, and
  # resolve the contract/group from the per-list value or the module default.
  network_lists = {
    for key, nl in var.network_lists : key => merge(nl, {
      type        = upper(nl.type)
      mode        = upper(nl.mode)
      contract_id = coalesce(nl.contract_id, var.contract_id)
      group_id    = coalesce(nl.group_id, var.group_id)
    })
  }
}

resource "akamai_networklist_network_list" "this" {
  for_each = local.network_lists

  name        = each.value.name
  type        = each.value.type
  description = each.value.description
  mode        = each.value.mode
  list        = each.value.entries

  # contract_id/group_id are optional on the resource; pass through only when set
  # so accounts that infer them from credentials still work. The resource's
  # group_id is numeric, so strip an optional "grp_" prefix and coerce to a number
  # (the input var accepts "grp_239808" or "239808" for ergonomics).
  contract_id = each.value.contract_id == null ? null : replace(each.value.contract_id, "ctr_", "")
  group_id    = each.value.group_id == null ? null : tonumber(replace(each.value.group_id, "grp_", ""))
}

# Activation is keyed on the same identifiers and gated by var.activate. The
# sync_point is read back from each managed list so the activation always ships
# the current version produced by the apply above.
resource "akamai_networklist_activations" "this" {
  for_each = var.activate ? local.network_lists : {}

  network_list_id     = akamai_networklist_network_list.this[each.key].uniqueid
  network             = upper(var.activation_network)
  sync_point          = akamai_networklist_network_list.this[each.key].sync_point
  notes               = var.activation_notes
  notification_emails = var.notification_emails

  lifecycle {
    precondition {
      condition     = !var.activate || length(var.notification_emails) > 0
      error_message = "notification_emails is required when activate = true."
    }
  }
}
