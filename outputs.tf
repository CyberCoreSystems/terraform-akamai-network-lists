output "network_list_ids" {
  description = "Map of list key to its network list ID (e.g. 86093_MYLIST). Feed these into appsec IP/geo firewalls or property rules."
  value       = { for key, nl in akamai_networklist_network_list.this : key => nl.uniqueid }
}

output "network_list_names" {
  description = "Map of list key to the network list name."
  value       = { for key, nl in akamai_networklist_network_list.this : key => nl.name }
}

output "sync_points" {
  description = "Map of list key to its current sync_point (version number)."
  value       = { for key, nl in akamai_networklist_network_list.this : key => nl.sync_point }
}

output "activation_statuses" {
  description = "Map of list key to its activation status (empty when activate = false)."
  value       = { for key, act in akamai_networklist_activations.this : key => act.status }
}
