# terraform-vault-consul-integration

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.2.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~>3.4.3 |
| <a name="requirement_vault"></a> [vault](#requirement\_vault) | ~>3.8.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | 3.4.3 |
| <a name="provider_vault"></a> [vault](#provider\_vault) | 3.8.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [random_id.gossip_token](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [random_uuid.boostrap_token](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) | resource |
| [vault_kubernetes_auth_backend_role.roles](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/kubernetes_auth_backend_role) | resource |
| [vault_kv_secret_v2.bootstrap_acl_token](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/kv_secret_v2) | resource |
| [vault_kv_secret_v2.consul_license](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/kv_secret_v2) | resource |
| [vault_kv_secret_v2.gossip](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/kv_secret_v2) | resource |
| [vault_mount.inter_ca](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/mount) | resource |
| [vault_mount.kvv2](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/mount) | resource |
| [vault_mount.root_ca](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/mount) | resource |
| [vault_pki_secret_backend_config_urls.inter_ca](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/pki_secret_backend_config_urls) | resource |
| [vault_pki_secret_backend_config_urls.root_ca](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/pki_secret_backend_config_urls) | resource |
| [vault_pki_secret_backend_intermediate_cert_request.inter_ca](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/pki_secret_backend_intermediate_cert_request) | resource |
| [vault_pki_secret_backend_intermediate_set_signed.inter_ca](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/pki_secret_backend_intermediate_set_signed) | resource |
| [vault_pki_secret_backend_role.inter_ca](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/pki_secret_backend_role) | resource |
| [vault_pki_secret_backend_root_cert.root_ca](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/pki_secret_backend_root_cert) | resource |
| [vault_pki_secret_backend_root_sign_intermediate.inter_ca](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/pki_secret_backend_root_sign_intermediate) | resource |
| [vault_policy.policies](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/resources/policy) | resource |
| [vault_auth_backend.kubernetes](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/data-sources/auth_backend) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_consul"></a> [consul](#input\_consul) | value | <pre>object({<br>    consul_connect = optional(object({<br>      enabled         = optional(bool, false)<br>      path            = optional(string, "consul_connect_int")<br>      pki_max_ttl     = optional(string, "2592000")<br>      pki_default_ttl = optional(string, "2592000")<br>      description     = optional(string, "PKI Secrets Engine for Consul Connect")<br>      common_name     = optional(string, "dc1.consul Intermediate Certificate Authority")<br>    }), {})<br>    consul_server = optional(object({<br>      enabled                    = optional(bool, false)<br>      path                       = optional(string, "consul_server_int")<br>      pki_max_ttl                = optional(string, "2592000")<br>      pki_default_ttl            = optional(string, "2592000")<br>      description                = optional(string, "PKI Secrets Engine for Consul TLS")<br>      common_name                = optional(string, "Consul Server Intermediate Certificate Authority")<br>      allowed_domains            = optional(list(string), ["dc1.consul", "consul-server", "consul-server.consul", "consul-server.consul.svc", "server.dc1.consul"])<br>      kubernetes_service_account = optional(string, "consul-server")<br>      kubernetes_namespace       = optional(string, "consul")<br>      vault_role_name            = optional(string, "consul-server")<br>      vault_role_policies        = optional(list(string), ["consul-ca-policy", "consul-bootstrap-token-policy", "consul-server-policy", "consul-license-policy", "consul-gossip-policy", "consul-connect-policy"])<br>      vault_role_ttl             = optional(string, "3600")<br>    }), {})<br>    consul_connect_inject = optional(object({<br>      enabled                    = optional(bool, false)<br>      path                       = optional(string, "consul_connect_inject_int")<br>      pki_max_ttl                = optional(string, "2592000")<br>      pki_default_ttl            = optional(string, "2592000")<br>      description                = optional(string, "PKI Secrets Engine for Consul Connect Inject")<br>      common_name                = optional(string, "consul-connect-injector")<br>      allowed_domains            = optional(list(string), ["consul-connect-injector", "consul-connect-injector.consul", "consul-connect-injector.consul.svc", "consul-connect-injector.consul.svc.cluster.local"])<br>      kubernetes_service_account = optional(string, "consul-connect-injector")<br>      kubernetes_namespace       = optional(string, "consul")<br>      vault_role_name            = optional(string, "consul-connect-inject")<br>      vault_role_policies        = optional(list(string), ["consul-connect-inject-policy"])<br>      vault_role_ttl             = optional(string, "3600")<br>    }), {})<br>    consul_controller = optional(object({<br>      enabled                    = optional(bool, false)<br>      path                       = optional(string, "consul_controller_int")<br>      pki_max_ttl                = optional(string, "2592000")<br>      pki_default_ttl            = optional(string, "2592000")<br>      description                = optional(string, "PKI Secrets Engine for Consul Controller")<br>      common_name                = optional(string, "consul-controller-webhook")<br>      allowed_domains            = optional(list(string), ["consul-controller-webhook", "consul-controller-webhook.consul", "consul-controller-webhook.consul.svc", "consul-controller-webhook.consul.svc.cluster.local"])<br>      kubernetes_service_account = optional(string, "consul-controller")<br>      kubernetes_namespace       = optional(string, "consul")<br>      vault_role_name            = optional(string, "consul-controller")<br>      vault_role_policies        = optional(list(string), ["consul-controller-policy"])<br>      vault_role_ttl             = optional(string, "3600")<br>    }), {})<br>    consul_client = optional(object({<br>      enabled                    = optional(bool, true)<br>      kubernetes_service_account = optional(string, "consul-client")<br>      kubernetes_namespace       = optional(string, "consul")<br>      vault_role_name            = optional(string, "consul-client")<br>      vault_role_policies        = optional(list(string), ["consul-ca-policy", "consul-gossip-policy"])<br>      vault_role_ttl             = optional(string, "3600")<br>    }), {})<br>    consul_ca = optional(object({<br>      enabled                    = optional(bool, true)<br>      kubernetes_service_account = optional(string, "*")<br>      kubernetes_namespace       = optional(string, "consul")<br>      vault_role_name            = optional(string, "consul-ca")<br>      vault_role_policies        = optional(list(string), ["consul-ca-policy"])<br>      vault_role_ttl             = optional(string, "3600")<br>    }), {})<br>    consul_server_acl = optional(object({<br>      enabled                    = optional(bool, false)<br>      kubernetes_service_account = optional(string, "consul-server-acl-init")<br>      kubernetes_namespace       = optional(string, "consul")<br>      vault_role_name            = optional(string, "consul-server-acl-init")<br>      vault_role_policies        = optional(list(string), ["consul-bootstrap-token-policy"])<br>      vault_role_ttl             = optional(string, "3600")<br>    }), {})<br>  })</pre> | n/a | yes |
| <a name="input_consul_license"></a> [consul\_license](#input\_consul\_license) | (Optional) Consul Enterprise license that will be used in the deployment. This is optional in case you do not want this license to be in the state file and want to manually create it later. If value is default then a random id will be written to var.kv\_path/license for you to change. The resource is set to be ignored to prevent Terraform from overwriting it | `string` | `""` | no |
| <a name="input_kv_description"></a> [kv\_description](#input\_kv\_description) | (Optional) Description for the KV-v2 store that Consul will use | `string` | `"KV-v2 store for Consul"` | no |
| <a name="input_kv_path"></a> [kv\_path](#input\_kv\_path) | (Optional) Path for the KV-v2 store that Consul will use | `string` | `"consul"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace that will be used for the configuration | `string` | `null` | no |
| <a name="input_root_ca_common_name"></a> [root\_ca\_common\_name](#input\_root\_ca\_common\_name) | (Optional) Common Name (CN) that will be associated with the generated root CA certificate | `string` | `"dc1.consul"` | no |
| <a name="input_root_ca_description"></a> [root\_ca\_description](#input\_root\_ca\_description) | (Optional) Description associated with the Root CA PKI Secrets Engine | `string` | `"Consul Root PKI Secrets Engine"` | no |
| <a name="input_root_ca_path"></a> [root\_ca\_path](#input\_root\_ca\_path) | (Optional) Path where the PKI secrets engine for the root CA path will be mounted in Vault | `string` | `"consul_pki"` | no |
| <a name="input_root_default_ttl"></a> [root\_default\_ttl](#input\_root\_default\_ttl) | (Optional) Default TTL for the Root CA Certs (in seconds) | `string` | `"315360000"` | no |
| <a name="input_root_max_ttl"></a> [root\_max\_ttl](#input\_root\_max\_ttl) | (Optional) Maximum TTL for the Root CA Certs (in seconds) | `string` | `"315360000"` | no |
| <a name="input_vault_kubernetes_auth_path"></a> [vault\_kubernetes\_auth\_path](#input\_vault\_kubernetes\_auth\_path) | (Optional) Path to mount the auth method. Defaults to kubernetes | `string` | `"kubernetes"` | no |
| <a name="input_vault_url"></a> [vault\_url](#input\_vault\_url) | (Required) URL for the Vault Server. This is used for all certificate issuing and CRLs. Eg. https://vault.bmrf.io:8200 or http://vault.bmrf.io:8200 or https://vault.bmrf.io (if using termination) | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_helm"></a> [helm](#output\_helm) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
