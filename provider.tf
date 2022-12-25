terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.36.1"
    }
    google = {
      source  = "hashicorp/google"
      version = "4.41.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "3.11.0"
    }
  }
}

provider "google" {
  project = "vpn-site-to-site-aws-gcp"
  region  = "us-east1"
}

provider "vault" {
  address = "http://18.204.230.186:8200"
  token   = var.token
}
