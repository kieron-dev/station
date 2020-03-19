Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/eoan64"
  config.vm.hostname = "eirini-station"

  config.vm.provider "virtualbox" do |vb|
    vb.name = 'eirini-station'

    vb.memory = (mem_total_mb * 0.8).round
    vb.cpus = num_cpus
  end


  config.vm.provision "shell", path: "provision.sh"

  config.vm.provision "shell" do |p|
    p.path = "provision-user.sh"
    p.privileged = false
    p.env = { "SSH_PRIVATE_KEY" => ENV.fetch('SSH_PRIVATE_KEY') }
  end
end

def num_cpus
  require 'etc'
  Etc.nprocessors
end

def mem_total_mb
  8192
end
