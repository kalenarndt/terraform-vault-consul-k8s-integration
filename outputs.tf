output "helm" {
  value       = local.outputs
  description = "Sample helm values file that contains all of the configured paths that were created with this module. This should be used a reference and not a raw input to another object"
}

output "kv-path" {
  value       = vault_mount.kvv2.path
  description = "Vault KV Path for the static secrets Consul is using"
}

output "bootstrap-token-name" {
  value = vault_kv_secret_v2.bootstrap_acl_token.name
}

output "consul-server-ca-path" {
  value       = var.consul.consul_server.enabled ? "${var.consul.consul_server.path}/cert/ca" : ""
  description = "Vault path to the Consul Server Intermediate CA"
}

output "consul-server-path" {
  value       = var.consul.consul_server.enabled ? "${var.consul.consul_server.path}/issue/${var.consul.consul_server.vault_role_name}" : ""
  description = "Vault path to the Consul Server Intermediate PKI path. Used to generate certificates"
}


output "consul-connect-path" {
  value       = var.consul.consul_connect.enabled ? "${var.consul.consul_connect.path}/" : ""
  description = "Vault path to the Consul Connect Intermediate CA"
}

output "consul-connect-inject-path" {
  value       = var.consul.consul_connect_inject.enabled ? "${var.consul.consul_connect_inject.path}/issue/${var.consul.consul_connect_inject.vault_role_name}" : ""
  description = "Vault path to the Consul Connect Inject Intermediate PKI path. Used to generate certificates"
}

output "consul-connect-inject-ca-path" {
  value       = var.consul.consul_connect_inject.enabled ? "${var.consul.consul_connect_inject.path}/cert/ca" : ""
  description = "Vault path to the Consul Controller Intermediate CA"
}

output "consul-controller-path" {
  value       = var.consul.consul_controller.enabled ? "${var.consul.consul_controller.path}/issue/${var.consul.consul_controller.vault_role_name}" : ""
  description = "Vault path to the Consul Controller Intermediate PKI path. Used to generate certificates"
}

output "consul-controller-ca-path" {
  value       = var.consul.consul_controller.enabled ? "${var.consul.consul_controller.path}/cert/ca" : ""
  description = "Vault path to the Consul Root CA"
}

output "consul-root-ca-path" {
  value       = "${var.root_ca_path}/"
  description = "Vault path to the Consul Root CA"
}

output "bootstrap-token-path" {
  value       = "${var.kv_path}/data/${vault_kv_secret_v2.bootstrap_acl_token.name}"
  description = "Vault path to the Consul ACL Bootstrap Token"
}

output "gossip-token-path" {
  value       = "${var.kv_path}/data/${vault_kv_secret_v2.gossip.name}"
  description = "Vault path to the Consul Gossip Token"
}

output "enterprise-license-path" {
  value       = "${var.kv_path}/data/${vault_kv_secret_v2.consul_license.name}"
  description = "Vault path to the Consul Enterprise License"
}

output "consul-server-role" {
  value       = var.consul.consul_server.enabled ? var.consul.consul_server.vault_role_name : ""
  description = "Vault role for Consul Server to use"
}

output "consul-client-role" {
  value       = var.consul.consul_client.enabled ? var.consul.consul_client.vault_role_name : ""
  description = "Vault role for Consul Client to use"
}

output "consul-ca-role" {
  value       = var.consul.consul_ca.enabled ? var.consul.consul_ca.vault_role_name : ""
  description = "Vault role for Consul CA to use"
}

output "consul-server-acl-role" {
  value       = var.consul.consul_server_acl.enabled ? var.consul.consul_server_acl.vault_role_name : ""
  description = "Vault role for Consul Manage System ACLs to use"
}

output "consul-controller-role" {
  value       = var.consul.consul_controller.enabled ? var.consul.consul_controller.vault_role_name : ""
  description = "Vault role for Consul Controller to use"
}

output "consul-connect-inject-role" {
  value       = var.consul.consul_connect_inject.enabled ? var.consul.consul_connect_inject.vault_role_name : ""
  description = "Vault role for Consul Connect Inject to use"
}
