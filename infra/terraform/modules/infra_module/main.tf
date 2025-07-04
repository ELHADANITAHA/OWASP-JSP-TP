# main.tf - Main Terraform module for infrastructure provisioning
# Provisions Vagrant VM, Docker containers, custom network, and handles Ansible and SAST setup

resource "local_file" "vagrant_config" {
  # Generate Vagrantfile from template
  filename = "${var.vagrant_base}/config/Vagrantfile"
  content  = templatefile("${var.vagrant_base}/templates/vagrantfile.tpl", {
    vm_name        = var.vm_name
    vm_box         = var.vm_box
    vm_box_version = var.vm_box_version
    vm_hostname    = var.vm_hostname
    vm_ip          = var.vm_ip
    vm_cpus        = var.vm_cpus
    vm_memory      = var.vm_memory
  })
}

resource "null_resource" "vagrant_control" {
  # Controls Vagrant VM lifecycle
  depends_on = [
    local_file.vagrant_config,
  ]

  triggers = {
    config_hash  = md5(local_file.vagrant_config.content)
    vagrant_base = tostring(var.vagrant_base)
  }

  provisioner "local-exec" {
    command = "cd ${var.vagrant_base}/config && vagrant up --provision"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "cd ${self.triggers.vagrant_base}/config && vagrant halt -f && vagrant destroy -f && rm -rf .vagrant"
  }
}

resource "local_file" "ansible_dockerfile" {
  # Generate Dockerfile for Ansible container
  filename = "${var.ansible_base}/config/Dockerfile"
  content  = templatefile("${var.ansible_base}/templates/dockerfile.tpl", {
    base_image = var.ansible_base_image
  })
}

resource "docker_image" "ansible_image" {
  # Build Ansible Docker image
  name = "ansible:local"
  build {
    context    = "${var.ansible_base}/config"
    dockerfile = "Dockerfile"
  }
  depends_on = [local_file.ansible_dockerfile]
}

resource "docker_container" "ansible_container" {
  # Run Ansible container for provisioning
  name        = "ansible-runner"
  image       = docker_image.ansible_image.image_id
  working_dir = "/ansible"
  tty         = true
  restart     = "unless-stopped"

  networks_advanced {
    name = docker_network.infra_bridge_network.name
  }

  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }
}

resource "null_resource" "copy_ansible_into_container" {
  # Copy Ansible Configuration, Vagrant private key for remote, and playbooks into container
  # This is necessary to ensure the Ansible container has the latest playbooks and configuration
  depends_on = [
    docker_container.ansible_container,
    null_resource.vagrant_control
  ]
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command = "docker cp ${var.ansible_base}/playbooks ansible-runner:/ansible && docker cp ${var.ansible_base}/config/run-ansible.sh ansible-runner:/ansible/run-ansible.sh && docker cp ${var.vagrant_base}/config/.vagrant/machines/default/virtualbox/private_key ansible-runner:/ansible/.vagrant_key && docker exec ansible-runner chmod 600 //ansible/.vagrant_key && docker exec ansible-runner chmod +x //ansible/run-ansible.sh"
  }
}

resource "null_resource" "run_ansible_playbook" {
  # Run all Ansible playbooks via run-ansible.sh inside container
  depends_on = [
    null_resource.copy_ansible_into_container,
    null_resource.vagrant_control
  ]
  provisioner "local-exec" {
    command = "docker exec ansible-runner /ansible/run-ansible.sh"
  }
}

resource "local_file" "sast_dockerfile" {
  # Generate Dockerfile for SAST (Trivy) container
  filename = "${var.sast_base}/config/Dockerfile"
  content  = templatefile("${var.sast_base}/templates/dockerfile.tpl", {
    base_image = var.sast_base_image
  })
}

resource "docker_image" "sast_image" {
  # Build SAST Docker image
  name = "sast:local"
  build {
    context    = "${var.sast_base}/config"
    dockerfile = "Dockerfile"
  }
  depends_on = [local_file.sast_dockerfile]
}

resource "docker_container" "sast_container" {
  # Run SAST container for security scanning
  name        = "sast-runner"
  image       = docker_image.sast_image.image_id
  working_dir = "/SAST"
  tty         = true
  restart     = "unless-stopped"

  networks_advanced {
    name = docker_network.infra_bridge_network.name
  }

  volumes {
    host_path      = "/var/run/docker.sock"
    container_path = "/var/run/docker.sock"
  }
}

resource "tls_private_key" "nginx_key" {
  # Generate private key for Nginx SSL
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "nginx_cert" {
  # Generate self-signed certificate for Nginx
  private_key_pem = tls_private_key.nginx_key.private_key_pem

  subject {
    common_name  = "localhost"
    organization = "JuiceShop"
  }

  validity_period_hours = 8760
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "local_file" "waf_fullchain" {
  filename = "${var.ansible_base}/playbooks/scripts/roles/waf_modsecurity/files/fullchain.pem"
  content  = tls_self_signed_cert.nginx_cert.cert_pem
}

resource "local_file" "waf_privkey" {
  filename = "${var.ansible_base}/playbooks/scripts/roles/waf_modsecurity/files/privkey.pem"
  content  = tls_private_key.nginx_key.private_key_pem
}
resource "docker_network" "infra_bridge_network" {
  # Create custom Docker bridge network for isolation
  name   = "infra_bridge_network"
  driver = "bridge"
}


# Run Trivy scan on Juice Shop image for security vulnerabilities SAST
resource "null_resource" "trivy_scan_after_hardening" {
  depends_on = [
    null_resource.run_ansible_playbook,
    docker_container.sast_container
  ]
  provisioner "local-exec" {
    command = "docker exec sast-runner bash -c 'trivy image bkimminich/juice-shop --format table --output //SAST/Scan_report_Juice-shop-image' || echo Trivy Juice Shop scan failed"
  }
}
