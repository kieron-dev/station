Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/eoan64"
  config.vm.hostname = "#{`hostname`[0..-2]}-eirini"

  config.vm.synced_folder "~/.gnupg", "/home/vagrant/.gnupg"
  config.vm.synced_folder "~/.ngrok2", "/home/vagrant/.ngrok2"

  config.disksize.size = '50GB'

  config.vm.provider "virtualbox" do |vb|
    vb.name = 'eirini-station'
    vb.memory = ENV.fetch('EIRINI_STATION_MEMORY', '8192').to_i
    vb.cpus = ENV.fetch('EIRINI_STATION_CPUS', '4').to_i

    # workaround for slow boot (https://bugs.launchpad.net/cloud-images/+bug/1829625)
    vb.customize ["modifyvm", :id, "--uart1", "0x3F8", "4"]
    vb.customize ["modifyvm", :id, "--uartmode1", "file", "./ttyS0.log"]
  end

  config.vm.network "public_network", bridge: [
    "en0: Wi-Fi (AirPort)",
    "en0: Wi-Fi (Wireless)",
  ]

  config.vm.provision "shell", path: "provision.sh"

  config.vm.provision "shell" do |p|
    p.path = "provision-user.sh"
    p.privileged = false
  end

  config.ssh.forward_agent = true
end
