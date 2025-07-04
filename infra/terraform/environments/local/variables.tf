# variables.tf - Terraform environment variables
# Sets the base path for relative module references

variable "base_path" {
  type = string
  default = "../../.."
}
