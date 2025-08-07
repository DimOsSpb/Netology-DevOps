terraform {
  required_providers {
    vault = {
      source = "hashicorp/vault"
      version = ">=5.0.0"
    }
  }
}

provider "vault" {
 address = "http://127.0.0.1:8200"
 skip_tls_verify = true
 token = "education"
}
data "vault_generic_secret" "vault_example"{
 path = "secret/example"
}

output "vault_example" {
 value = "${nonsensitive(data.vault_generic_secret.vault_example.data)}"
} 

resource "vault_generic_secret" "my_example" {
  path = "secret/my_example"

  data_json = <<EOT
    {
        "new":   "secret"
    }
    EOT
}
