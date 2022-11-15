terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.36.1"
    }
    google = {
      source = "hashicorp/google"
      version = "4.41.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "google" {
  project = "aws-gcp-tutorial"
  region = "us-east1"
}