# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'etc'
require 'total'

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"

  config.vm.provider "virtualbox" do |vb|
    vb.name = 'eirini-station'

    vb.cpus = Etc.nprocessors
    vb.memory = (mem_total_mb * 0.8).round
  end

  config.vm.provision "shell", path: "provision.sh"
  config.vm.provision "shell", path: "provision-user.sh", privileged: false
end

def mem_total_mb
  Total::Mem.new.bytes / (1024 * 1024)
end
