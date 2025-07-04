# vagrantfile.tpl - Vagrant VM configuration template
# This template is rendered by Terraform to provision the VM for Juice Shop infrastructure

# Ruby mode and Vagrantfile settings
# -*- mode: ruby -*-
# vi: set ft=ruby -*-

Vagrant.configure("2") do |config|
  # Base box and version
  config.vm.box = "${vm_box}"
  config.vm.box_version = "${vm_box_version}"
  config.vm.box_check_update = false

  # Hostname and networking
  config.vm.hostname = "${vm_hostname}"
  config.vm.network "private_network", ip: "${vm_ip}"
  config.vm.boot_timeout = 300
  config.vm.network "forwarded_port", guest: 2375, host: 2375  # Docker socket forwarding

  # VirtualBox provider settings
  config.vm.provider "virtualbox" do |vb|
    vb.memory = ${vm_memory}         # VM memory allocation
    vb.cpus = ${vm_cpus}            # VM CPU allocation
    vb.name = "${vm_name}"
    vb.gui = false
    vb.customize ["modifyvm", :id, "--ioapic", "on"]
  end
end
