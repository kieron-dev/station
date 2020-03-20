Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/eoan64"
  config.vm.hostname = "eirini-station"

  config.vm.provider "virtualbox" do |vb|
    vb.name = 'eirini-station'
    vb.memory = 8192
    vb.cpus = 4

    # workaround for slow boot (https://bugs.launchpad.net/cloud-images/+bug/1829625)
    vb.customize ["modifyvm", :id, "--uart1", "0x3F8", "4"]
    vb.customize ["modifyvm", :id, "--uartmode1", "file", "./ttyS0.log"]
  end


  config.vm.provision "shell", path: "provision.sh"

  config.vm.provision "shell" do |p|
    p.path = "provision-user.sh"
    p.privileged = false
  end

  config.ssh.forward_agent = true
end

def num_cpus
  require 'etc'
  Etc.nprocessors
end

def mem_total_mb
  8192
end
