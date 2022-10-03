module "vault-k8s-consul" {
  source                     = "../../"
  vault_url                  = "http://172.16.0.158:8200"
  vault_kubernetes_auth_path = "kubernetes"
  consul = {
    consul_ca = {
      enabled = true
    }
    consul_client = {
      enabled = true
    }
    consul_connect = {
      enabled = true
    }
    consul_server = {
      enabled = true
    }
    consul_server_acl = {
      enabled = true
    }
    consul_connect_inject = {
      enabled = true
    }
    consul_controller = {
      enabled = true
    }
  }
}
