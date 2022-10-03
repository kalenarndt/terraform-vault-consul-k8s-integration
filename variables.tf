variable "namespace" {
  description = "Namespace that will be used for the configuration"
  type        = string
  default     = null
}

variable "vault_url" {
  type        = string
  description = "(Required) URL for the Vault Server. This is used for all certificate issuing and CRLs. Eg. https://vault.bmrf.io:8200 or http://vault.bmrf.io:8200 or https://vault.bmrf.io (if using termination)"
}

variable "kv_path" {
  type        = string
  description = "(Optional) Path for the KV-v2 store that Consul will use"
  default     = "consul"
}

variable "kv_description" {
  type        = string
  description = "(Optional) Description for the KV-v2 store that Consul will use"
  default     = "KV-v2 store for Consul"
}


variable "root_ca_path" {
  type        = string
  description = "(Optional) Path where the PKI secrets engine for the root CA path will be mounted in Vault"
  default     = "consul_pki"
}

variable "root_ca_description" {
  type        = string
  description = "(Optional) Description associated with the Root CA PKI Secrets Engine"
  default     = "Consul Root PKI Secrets Engine"
}

variable "root_ca_common_name" {
  type        = string
  description = "(Optional) Common Name (CN) that will be associated with the generated root CA certificate"
  default     = "dc1.consul"
}

variable "root_max_ttl" {
  type        = string
  description = "(Optional) Maximum TTL for the Root CA Certs (in seconds)"
  default     = "315360000"
}

variable "root_default_ttl" {
  type        = string
  description = "(Optional) Default TTL for the Root CA Certs (in seconds)"
  default     = "315360000"
}

variable "consul" {
  type = object({
    consul_connect = optional(object({
      enabled         = optional(bool, false)
      path            = optional(string, "consul_connect_int")
      pki_max_ttl     = optional(string, "2592000")
      pki_default_ttl = optional(string, "2592000")
      description     = optional(string, "PKI Secrets Engine for Consul Connect")
      common_name     = optional(string, "dc1.consul Intermediate Certificate Authority")
    }), {})
    consul_server = optional(object({
      enabled                    = optional(bool, false)
      path                       = optional(string, "consul_server_int")
      pki_max_ttl                = optional(string, "2592000")
      pki_default_ttl            = optional(string, "2592000")
      description                = optional(string, "PKI Secrets Engine for Consul TLS")
      common_name                = optional(string, "Consul Server Intermediate Certificate Authority")
      allowed_domains            = optional(list(string), ["dc1.consul", "consul-server", "consul-server.consul", "consul-server.consul.svc", "server.dc1.consul"])
      kubernetes_service_account = optional(string, "consul-server")
      kubernetes_namespace       = optional(string, "consul")
      vault_role_name            = optional(string, "consul-server")
      vault_role_policies        = optional(list(string), ["consul-ca-policy", "consul-bootstrap-token-policy", "consul-server-policy", "consul-license-policy", "consul-gossip-policy", "consul-connect-policy"])
      vault_role_ttl             = optional(string, "3600")
    }), {})
    consul_connect_inject = optional(object({
      enabled                    = optional(bool, false)
      path                       = optional(string, "consul_connect_inject_int")
      pki_max_ttl                = optional(string, "2592000")
      pki_default_ttl            = optional(string, "2592000")
      description                = optional(string, "PKI Secrets Engine for Consul Connect Inject")
      common_name                = optional(string, "consul-connect-injector")
      allowed_domains            = optional(list(string), ["consul-connect-injector", "consul-connect-injector.consul", "consul-connect-injector.consul.svc", "consul-connect-injector.consul.svc.cluster.local"])
      kubernetes_service_account = optional(string, "consul-connect-injector")
      kubernetes_namespace       = optional(string, "consul")
      vault_role_name            = optional(string, "consul-connect-inject")
      vault_role_policies        = optional(list(string), ["consul-connect-inject-policy"])
      vault_role_ttl             = optional(string, "3600")
    }), {})
    consul_controller = optional(object({
      enabled                    = optional(bool, false)
      path                       = optional(string, "consul_controller_int")
      pki_max_ttl                = optional(string, "2592000")
      pki_default_ttl            = optional(string, "2592000")
      description                = optional(string, "PKI Secrets Engine for Consul Controller")
      common_name                = optional(string, "consul-controller-webhook")
      allowed_domains            = optional(list(string), ["consul-controller-webhook", "consul-controller-webhook.consul", "consul-controller-webhook.consul.svc", "consul-controller-webhook.consul.svc.cluster.local"])
      kubernetes_service_account = optional(string, "consul-controller")
      kubernetes_namespace       = optional(string, "consul")
      vault_role_name            = optional(string, "consul-controller")
      vault_role_policies        = optional(list(string), ["consul-controller-policy"])
      vault_role_ttl             = optional(string, "3600")
    }), {})
    consul_client = optional(object({
      enabled                    = optional(bool, true)
      kubernetes_service_account = optional(string, "consul-client")
      kubernetes_namespace       = optional(string, "consul")
      vault_role_name            = optional(string, "consul-client")
      vault_role_policies        = optional(list(string), ["consul-ca-policy", "consul-gossip-policy"])
      vault_role_ttl             = optional(string, "3600")
    }), {})
    consul_ca = optional(object({
      enabled                    = optional(bool, true)
      kubernetes_service_account = optional(string, "*")
      kubernetes_namespace       = optional(string, "consul")
      vault_role_name            = optional(string, "consul-ca")
      vault_role_policies        = optional(list(string), ["consul-ca-policy"])
      vault_role_ttl             = optional(string, "3600")
    }), {})
    consul_server_acl = optional(object({
      enabled                    = optional(bool, false)
      kubernetes_service_account = optional(string, "consul-server-acl-init")
      kubernetes_namespace       = optional(string, "consul")
      vault_role_name            = optional(string, "consul-server-acl-init")
      vault_role_policies        = optional(list(string), ["consul-bootstrap-token-policy"])
      vault_role_ttl             = optional(string, "3600")
    }), {})
  })
  description = "(Required) Object map of all of the integrations that will be configured in HashiCorp Vault. This does not support configuring your own policies. If you are disabling specific services (Connect) ensure that you remove the corresponding policy assocations from the other sub-entries (consul_server). By default, the inputs required for this are only enabled=true for the object to create the other secrets engines and policies. Policies are located in the tmpl folder if you would like to inspect them."
}


variable "vault_kubernetes_auth_path" {
  type        = string
  description = "(Optional) Path to mount the auth method. Defaults to kubernetes"
  default     = "kubernetes"
}


variable "consul_license" {
  type        = string
  description = "(Optional) Consul Enterprise license that will be used in the deployment. This is optional in case you do not want this license to be in the state file and want to manually create it later. If value is default then a random id will be written to var.kv_path/license for you to change. The resource is set to be ignored to prevent Terraform from overwriting it"
  default     = ""
}
