variable "key_name" {
  default = "cms-karl"
}

variable "security_group_default" {
  default = {
    name = "default"
    id = "sg-5973d520"
  }
}

variable "postgres_master_creds" {
  default = {
    username = "postgres"
    # FIXME password should not be stored here in cleartext
    # FIXME Terraform's output `*.tfstate` file tracks this in plaintext.
    password = "secretsecret"
  }
}

variable chefadmin_password {
    # FIXME password should not be stored here in cleartext
  default = "secretsecret"
}
