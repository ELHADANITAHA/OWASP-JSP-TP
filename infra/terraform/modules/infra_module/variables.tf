# variables.tf - Terraform variables for infrastructure module
# Defines all configurable parameters for VM, Docker, Ansible, and SAST

variable "vm_box" {
  type    = string
  default = "bento/ubuntu-24.04"
}

variable "vm_box_version" {
  type    = string
  default = "202502.21.0"
}

variable "vm_hostname" {
  type    = string
  default = "juice.sh"
}

variable "server_domain" {
  type    = string
  default = "juice-sh.op"
}

variable "vm_name" {
  type    = string
  default = "juice-shop-vm"
}

variable "vm_ip" {
  type    = string
  default = "192.168.56.110"
}

variable "vm_cpus" {
  type    = number
  default = 2
}

variable "vm_memory" {
  type    = number
  default = 2048
}

variable "ansible_base" {
  type        = string
  description = "Base path to docker/Ansible directory"
}

variable "sast_base" {
  type        = string
  description = "Base path to docker/SAST (Trivy SAST) directory"
}

variable "vagrant_base" {
  type        = string
  description = "Base path to vagrant directory"
}

variable "ansible_base_image" {
  description = "Base image for Ansible Docker container"
  type        = string
  default     = "ubuntu:24.04"
}

variable "sast_base_image" {
  description = "Base image for SAST (Trivy) Docker container"
  type        = string
  default     = "ubuntu:24.04"
}

variable "ansible_container_name" {
  description = "Name of the Ansible Docker container"
  type        = string
  default     = "ansible-runner"
}

variable "ansible_workdir" {
  description = "Working directory inside Ansible container"
  type        = string
  default     = "/ansible"
}

variable "sast_workdir" {
  description = "Working directory inside SAST container"
  type        = string
  default     = "/sast"
}

