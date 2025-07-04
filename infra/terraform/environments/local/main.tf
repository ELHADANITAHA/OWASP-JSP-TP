# main.tf - Terraform environment entry point
# Calls the main infrastructure module with environment-specific paths

module "infra_module" {
  source = "../../modules/infra_module"
  sast_base = "${var.base_path}/docker/SAST"
  ansible_base = "${var.base_path}/docker/Ansible"
  vagrant_base = "${var.base_path}/vagrant"
}