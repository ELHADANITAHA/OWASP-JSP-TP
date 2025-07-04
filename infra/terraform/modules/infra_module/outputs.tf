# outputs.tf - Terraform outputs for infrastructure module
# Provides useful information after provisioning (application URL, SSH command)

output "application_url" {
  value = "https://${var.vm_ip}"
}

output "ssh_command" {
  value = "cd ../vagrant && vagrant ssh"
}