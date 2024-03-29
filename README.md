# terraform-vault-consul-k8s-integration

> **Warning**
> This module is under active development
This module assumes you have a kubernetes auth method already configured in Vault

This module builds the Root CA, Server TLS Intermediate, Consul Connect Intermediate, Connect Inject Intermediate, Controller Intermediate, KV Secrets Engine, Bootstrap Tokens, Gossip Tokens, Consul Licenses, Vault Policies, Kubernetes Roles for authentication with the policies associated, and outputs a sample helm values file.

> **Note**
> This module doesn't support BYO policies for Vault. If you want to modify the policy files they are located in the `tmpl` directory.
> If you disable Consul Connect please make sure you remove the policy reference in the object map for `consul_server` or the templating will fail

Super open to PRs on this module or even code reviews. Go forth and fork!

## TODO

- [ ] Optimize Locals (Reduce the amount)
- [ ] Change local `k,v` references to be something that is easier to read
- [ ] Work on dynamic evaluation of supplied policies in `vault_role_policies` where if a role isn't enabled but is referenced it should be filtered and removed so templating doesn't fail
- [ ] Use `templatefile` for generating output that reflects what was configured. Currently it wont template the path if it isn't configured but doesn't remove the section in the sample helm values

---

### Diagrams

#### Auth Method / Role to K8s Account / Namespace Diagram

![auth-role-diagram](diagrams/auth-roles.png)

#### Vault KV Secrets to Helm Values Diagram

![vault-kv-helm-value](diagrams/kv-secrets.png)

---

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.3.0 |
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
| <a name="input_consul"></a> [consul](#input\_consul) | (Required) Object map of all of the integrations that will be configured in HashiCorp Vault. This does not support configuring your own policies. If you are disabling specific services (Connect) ensure that you remove the corresponding policy assocations from the other sub-entries (consul\_server). By default, the inputs required for this are only enabled=true for the object to create the other secrets engines and policies. Policies are located in the tmpl folder if you would like to inspect them. | <pre>object({<br>    consul_connect = optional(object({<br>      enabled         = optional(bool, false)<br>      path            = optional(string, "consul_connect_int")<br>      pki_max_ttl     = optional(string, "2592000")<br>      pki_default_ttl = optional(string, "2592000")<br>      description     = optional(string, "PKI Secrets Engine for Consul Connect")<br>      common_name     = optional(string, "dc1.consul Intermediate Certificate Authority")<br>    }), {})<br>    consul_server = optional(object({<br>      enabled                    = optional(bool, false)<br>      path                       = optional(string, "consul_server_int")<br>      pki_max_ttl                = optional(string, "2592000")<br>      pki_default_ttl            = optional(string, "2592000")<br>      description                = optional(string, "PKI Secrets Engine for Consul TLS")<br>      common_name                = optional(string, "Consul Server Intermediate Certificate Authority")<br>      allowed_domains            = optional(list(string), ["dc1.consul", "consul-server", "consul-server.consul", "consul-server.consul.svc", "server.dc1.consul"])<br>      kubernetes_service_account = optional(string, "consul-server")<br>      kubernetes_namespace       = optional(string, "consul")<br>      vault_role_name            = optional(string, "consul-server")<br>      vault_role_policies        = optional(list(string), ["consul-ca-policy", "consul-bootstrap-token-policy", "consul-server-policy", "consul-license-policy", "consul-gossip-policy", "consul-connect-policy"])<br>      vault_role_ttl             = optional(string, "3600")<br>    }), {})<br>    consul_connect_inject = optional(object({<br>      enabled                    = optional(bool, false)<br>      path                       = optional(string, "consul_connect_inject_int")<br>      pki_max_ttl                = optional(string, "2592000")<br>      pki_default_ttl            = optional(string, "2592000")<br>      description                = optional(string, "PKI Secrets Engine for Consul Connect Inject")<br>      common_name                = optional(string, "consul-connect-injector")<br>      allowed_domains            = optional(list(string), ["consul-connect-injector", "consul-connect-injector.consul", "consul-connect-injector.consul.svc", "consul-connect-injector.consul.svc.cluster.local"])<br>      kubernetes_service_account = optional(string, "consul-connect-injector")<br>      kubernetes_namespace       = optional(string, "consul")<br>      vault_role_name            = optional(string, "consul-connect-inject")<br>      vault_role_policies        = optional(list(string), ["consul-connect-inject-policy"])<br>      vault_role_ttl             = optional(string, "3600")<br>    }), {})<br>    consul_controller = optional(object({<br>      enabled                    = optional(bool, false)<br>      path                       = optional(string, "consul_controller_int")<br>      pki_max_ttl                = optional(string, "2592000")<br>      pki_default_ttl            = optional(string, "2592000")<br>      description                = optional(string, "PKI Secrets Engine for Consul Controller")<br>      common_name                = optional(string, "consul-controller-webhook")<br>      allowed_domains            = optional(list(string), ["consul-controller-webhook", "consul-controller-webhook.consul", "consul-controller-webhook.consul.svc", "consul-controller-webhook.consul.svc.cluster.local"])<br>      kubernetes_service_account = optional(string, "consul-controller")<br>      kubernetes_namespace       = optional(string, "consul")<br>      vault_role_name            = optional(string, "consul-controller")<br>      vault_role_policies        = optional(list(string), ["consul-controller-policy"])<br>      vault_role_ttl             = optional(string, "3600")<br>    }), {})<br>    consul_client = optional(object({<br>      enabled                    = optional(bool, true)<br>      kubernetes_service_account = optional(string, "consul-client")<br>      kubernetes_namespace       = optional(string, "consul")<br>      vault_role_name            = optional(string, "consul-client")<br>      vault_role_policies        = optional(list(string), ["consul-ca-policy", "consul-gossip-policy"])<br>      vault_role_ttl             = optional(string, "3600")<br>    }), {})<br>    consul_ca = optional(object({<br>      enabled                    = optional(bool, true)<br>      kubernetes_service_account = optional(string, "*")<br>      kubernetes_namespace       = optional(string, "consul")<br>      vault_role_name            = optional(string, "consul-ca")<br>      vault_role_policies        = optional(list(string), ["consul-ca-policy"])<br>      vault_role_ttl             = optional(string, "3600")<br>    }), {})<br>    consul_server_acl = optional(object({<br>      enabled                    = optional(bool, false)<br>      kubernetes_service_account = optional(string, "consul-server-acl-init")<br>      kubernetes_namespace       = optional(string, "consul")<br>      vault_role_name            = optional(string, "consul-server-acl-init")<br>      vault_role_policies        = optional(list(string), ["consul-bootstrap-token-policy"])<br>      vault_role_ttl             = optional(string, "3600")<br>    }), {})<br>  })</pre> | <pre>{<br>  "consul_ca": {<br>    "enabled": true<br>  },<br>  "consul_client": {<br>    "enabled": true<br>  },<br>  "consul_connect": {<br>    "enabled": true<br>  },<br>  "consul_connect_inject": {<br>    "enabled": true<br>  },<br>  "consul_controller": {<br>    "enabled": true<br>  },<br>  "consul_server": {<br>    "enabled": true<br>  },<br>  "consul_server_acl": {<br>    "enabled": true<br>  }<br>}</pre> | no |
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
| <a name="output_bootstrap-token-name"></a> [bootstrap-token-name](#output\_bootstrap-token-name) | n/a |
| <a name="output_bootstrap-token-path"></a> [bootstrap-token-path](#output\_bootstrap-token-path) | Vault path to the Consul ACL Bootstrap Token |
| <a name="output_consul-ca-role"></a> [consul-ca-role](#output\_consul-ca-role) | Vault role for Consul CA to use |
| <a name="output_consul-client-role"></a> [consul-client-role](#output\_consul-client-role) | Vault role for Consul Client to use |
| <a name="output_consul-connect-inject-ca-path"></a> [consul-connect-inject-ca-path](#output\_consul-connect-inject-ca-path) | Vault path to the Consul Controller Intermediate CA |
| <a name="output_consul-connect-inject-path"></a> [consul-connect-inject-path](#output\_consul-connect-inject-path) | Vault path to the Consul Connect Inject Intermediate PKI path. Used to generate certificates |
| <a name="output_consul-connect-inject-role"></a> [consul-connect-inject-role](#output\_consul-connect-inject-role) | Vault role for Consul Connect Inject to use |
| <a name="output_consul-connect-path"></a> [consul-connect-path](#output\_consul-connect-path) | Vault path to the Consul Connect Intermediate CA |
| <a name="output_consul-controller-ca-path"></a> [consul-controller-ca-path](#output\_consul-controller-ca-path) | Vault path to the Consul Root CA |
| <a name="output_consul-controller-path"></a> [consul-controller-path](#output\_consul-controller-path) | Vault path to the Consul Controller Intermediate PKI path. Used to generate certificates |
| <a name="output_consul-controller-role"></a> [consul-controller-role](#output\_consul-controller-role) | Vault role for Consul Controller to use |
| <a name="output_consul-root-ca-path"></a> [consul-root-ca-path](#output\_consul-root-ca-path) | Vault path to the Consul Root CA |
| <a name="output_consul-server-acl-role"></a> [consul-server-acl-role](#output\_consul-server-acl-role) | Vault role for Consul Manage System ACLs to use |
| <a name="output_consul-server-ca-path"></a> [consul-server-ca-path](#output\_consul-server-ca-path) | Vault path to the Consul Server Intermediate CA |
| <a name="output_consul-server-path"></a> [consul-server-path](#output\_consul-server-path) | Vault path to the Consul Server Intermediate PKI path. Used to generate certificates |
| <a name="output_consul-server-role"></a> [consul-server-role](#output\_consul-server-role) | Vault role for Consul Server to use |
| <a name="output_enterprise-license-path"></a> [enterprise-license-path](#output\_enterprise-license-path) | Vault path to the Consul Enterprise License |
| <a name="output_gossip-token-path"></a> [gossip-token-path](#output\_gossip-token-path) | Vault path to the Consul Gossip Token |
| <a name="output_helm"></a> [helm](#output\_helm) | Sample helm values file that contains all of the configured paths that were created with this module. This should be used a reference and not a raw input to another object |
| <a name="output_kv-path"></a> [kv-path](#output\_kv-path) | Vault KV Path for the static secrets Consul is using |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
