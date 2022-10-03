locals {
  consul_enabled = {
    for k, v in var.consul : k => v
    if try(v.path, "") != "" && try(v.enabled, false) == true
  }

  consul_roles = {
    for k, v in var.consul : k => v
    if try(v.enabled, false) == true && try(v.vault_role_name, "") != ""
  }
}

locals {

  enabled_integrations = {
    for k, v in var.consul : k => v if try(v.enabled, false) == true && try(v.vault_role_name, "") != "" || try(v.enabled, false) == true && try(k, "") == "consul_connect"
  }


  # Map of enabled integrations and their paths used for templating Vault policies
  consul_paths = {
    for integration, values in local.enabled_integrations : "${integration}_path" => values.path if try(values.path, "") != ""
  }

  # Map of roles and the role_name used for templating the Vault policies
  consul_vault_roles = {
    for integration, values in local.enabled_integrations : "${integration}_role" => values.vault_role_name if try(values.vault_role_name, "") != "" && try(values.path, "") != ""
  }

  # Merged map of the roles and paths along with the root_ca paths and kv_path
  merged = merge(local.consul_paths, local.consul_vault_roles, { "kv_path" = var.kv_path }, { "root_ca_path" = var.root_ca_path })

  # Deduped list of policies for the enabled roles for Consul integration
  enabled_role_policies = distinct(flatten(values({
    for k, v in local.enabled_integrations : k => v.vault_role_policies if try(v.vault_role_policies, null) != null
  })))

  # for_each that templates out all the files
  policy_templates = {
    for k, v in local.enabled_role_policies : v => {
      template = templatefile("${path.module}/tmpl/${v}.hcl.tftpl", local.merged),
    }
  }
}

resource "vault_mount" "kvv2" {
  namespace   = var.namespace
  path        = var.kv_path
  type        = "kv-v2"
  description = var.kv_description
}

resource "vault_mount" "root_ca" {
  namespace                 = var.namespace
  path                      = var.root_ca_path
  type                      = "pki"
  description               = var.root_ca_description
  default_lease_ttl_seconds = var.root_default_ttl
  max_lease_ttl_seconds     = var.root_max_ttl
}

resource "vault_pki_secret_backend_config_urls" "root_ca" {
  namespace               = var.namespace
  backend                 = vault_mount.root_ca.path
  issuing_certificates    = ["${var.vault_url}/v1/${vault_mount.root_ca.path}/ca"]
  crl_distribution_points = ["${var.vault_url}/v1/${vault_mount.root_ca.path}/crl"]
}

resource "vault_pki_secret_backend_root_cert" "root_ca" {
  namespace   = var.namespace
  backend     = vault_mount.root_ca.path
  type        = "internal"
  common_name = var.root_ca_common_name
}

# I need to work through the structuring for this
resource "vault_mount" "inter_ca" {
  for_each                  = local.consul_enabled
  namespace                 = var.namespace
  path                      = each.value.path
  type                      = "pki"
  description               = each.value.description
  max_lease_ttl_seconds     = each.value.pki_max_ttl
  default_lease_ttl_seconds = each.value.pki_default_ttl
}

# Need to work on the variable structuring
resource "vault_pki_secret_backend_config_urls" "inter_ca" {
  for_each                = local.consul_enabled
  namespace               = var.namespace
  backend                 = vault_mount.inter_ca[each.key].path
  issuing_certificates    = ["${var.vault_url}/v1/${vault_mount.inter_ca[each.key].path}/ca"]
  crl_distribution_points = ["${var.vault_url}/v1/${vault_mount.inter_ca[each.key].path}/crl"]
}

# Need to work on the logic and variable structuring here
resource "vault_pki_secret_backend_intermediate_cert_request" "inter_ca" {
  for_each    = local.consul_enabled
  namespace   = var.namespace
  backend     = vault_mount.inter_ca[each.key].path
  type        = vault_pki_secret_backend_root_cert.root_ca.type
  common_name = each.value.common_name
}

# Need to work on the logic and variable structuring here
resource "vault_pki_secret_backend_root_sign_intermediate" "inter_ca" {
  for_each             = local.consul_enabled
  backend              = vault_mount.root_ca.path
  csr                  = vault_pki_secret_backend_intermediate_cert_request.inter_ca[each.key].csr
  common_name          = each.value.common_name
  exclude_cn_from_sans = true
  revoke               = true
  format               = "pem_bundle"
}

resource "vault_pki_secret_backend_intermediate_set_signed" "inter_ca" {
  for_each    = local.consul_enabled
  backend     = vault_mount.inter_ca[each.key].path
  certificate = vault_pki_secret_backend_root_sign_intermediate.inter_ca[each.key].certificate
}


resource "vault_pki_secret_backend_role" "inter_ca" {
  for_each         = { for k, v in local.consul_enabled : k => v if try(v.allowed_domains, [""]) != [""] }
  namespace        = var.namespace
  backend          = vault_mount.inter_ca[each.key].path
  name             = each.key
  max_ttl          = each.value.pki_max_ttl
  allow_ip_sans    = true
  allowed_domains  = each.value.allowed_domains
  allow_subdomains = true
  allow_localhost  = true
  generate_lease   = true
}


data "vault_auth_backend" "kubernetes" {
  namespace = var.namespace
  path      = var.vault_kubernetes_auth_path
}

resource "vault_policy" "policies" {
  for_each  = local.policy_templates
  namespace = var.namespace
  name      = each.key
  policy    = each.value.template
}


resource "vault_kubernetes_auth_backend_role" "roles" {
  for_each                         = local.consul_roles
  namespace                        = var.namespace
  backend                          = data.vault_auth_backend.kubernetes.path
  role_name                        = each.value.vault_role_name
  bound_service_account_names      = [each.value.kubernetes_service_account]
  bound_service_account_namespaces = [each.value.kubernetes_namespace]
  token_ttl                        = each.value.vault_role_ttl
  token_policies                   = each.value.vault_role_policies
}

resource "random_id" "gossip_token" {
  byte_length = 32
}

resource "random_uuid" "boostrap_token" {
}

resource "vault_kv_secret_v2" "gossip" {
  namespace = var.namespace
  mount     = vault_mount.kvv2.path
  name      = "gossip-token"
  data_json = jsonencode({
    "token" = random_id.gossip_token.b64_std
  })
}

resource "vault_kv_secret_v2" "bootstrap_acl_token" {
  namespace = var.namespace
  mount     = vault_mount.kvv2.path
  name      = "bootstrap-token"
  data_json = jsonencode({
    "token" = random_uuid.boostrap_token.result
  })
}

resource "vault_kv_secret_v2" "consul_license" {
  namespace = var.namespace
  mount     = vault_mount.kvv2.path
  name      = "consul-license"
  data_json = jsonencode({
    "license" = var.consul_license != "" ? var.consul_license : ""
  })
  lifecycle {
    ignore_changes = [
      data_json
    ]
  }
}


locals {
  outputs = <<EOF
  global:
    image: "hashicorp/consul-enterprise:1.12.3-ent"
    datacenter: dc1
    name: consul
    domain: consul
  enterpriseLicense:
    secretName: ${var.kv_path}/data/${vault_kv_secret_v2.consul_license.name}
    secretKey: license
    enableLicenseAutoload: true
  secretsBackend:
    vault:
      enabled: true
      consulServerRole: ${try(var.consul.consul_server.enabled, false) == true ? var.consul.consul_server.vault_role_name : ""}
      consulClientRole: ${try(var.consul.consul_client.enabled, false) == true ? var.consul.consul_client.vault_role_name : ""}
      consulCARole: ${try(var.consul.consul_ca.enabled, false) == true ? var.consul.consul_ca.vault_role_name : ""}
      manageSystemACLsRole: ${try(var.consul.consul_server_acl.enabled, false) == true ? var.consul.consul_server_acl.vault_role_name : ""}
      controllerRole: ${try(var.consul.consul_controller.enabled, false) == true ? var.consul.consul_controller.vault_role_name : ""}
      connectInjectRole: ${try(var.consul.consul_connect_inject.enabled, false) == true ? var.consul.consul_connect_inject.vault_role_name : ""}
      controller:
        caCert:
          secretName: "${try(var.consul.consul_controller.enabled, false) == true ? var.consul.consul_controller.path : ""}/cert/ca
        tlsCert:
          secretName: "${try(var.consul.consul_controller.enabled, false) == true ? var.consul.consul_controller.path : ""}/issue/${try(var.consul.consul_controller.enabled, false) == true ? var.consul.consul_controller.vault_role_name : ""}"
      connectInject:
        caCert:
          secretName: "${try(var.consul.consul_connect_inject.enabled, false) == true ? var.consul.consul_connect_inject.path : ""}/cert/ca"
        tlsCert:
          secretName: "${try(var.consul.consul_connect_inject.enabled, false) == true ? var.consul.consul_connect_inject.path : ""}/issue/${try(var.consul.consul_controller.enabled, false) == true ? var.consul.consul_controller.vault_role_name : ""}"
      connectCA:
        address: ${var.vault_url}
        rootPKIPath: ${var.root_ca_path}/
        intermediatePKIPath: ${try(var.consul.consul_connect.enabled, false) == true ? var.consul.consul_connect.path : ""}/

  gossipEncryption:
    autoGenerate: false
    secretName: ${var.kv_path}/data/${vault_kv_secret_v2.gossip.name}
    secretKey: token

  acls:
    manageSystemACLs: true
    bootstrapToken:
      secretName: ${var.kv_path}/data/${vault_kv_secret_v2.bootstrap_acl_token.name}
      secretKey: token
    createReplicationToken: true

  tls:
    enableAutoEncrypt: true
    enabled: true
    httpsOnly: true
    verify: true
    caCert:
      secretName: "${try(var.consul.consul_server.enabled, false) == true ? var.consul.consul_server.path : ""}/cert/ca"

server:
  serverCert:
    secretName: "${try(var.consul.consul_server.enabled, false) == true ? var.consul.consul_server.path : ""}/issue/${try(var.consul.consul_server.enabled, false) == true ? var.consul.consul_server.vault_role_name : ""}"
  connect: true
  EOF
}
