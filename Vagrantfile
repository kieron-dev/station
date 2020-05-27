Vagrant.configure("2") do |config|
  config.vm.hostname = "#{`hostname`[0..-2]}-eirini"
  config.ssh.forward_agent = true

  config.vm.provision "shell", path: "provision.sh"
  config.vm.provision "shell" do |p|
    p.path = "provision-user.sh"
    p.privileged = false
  end

  config.vm.provider "virtualbox" do |vb, override|
    vb.name = 'eirini-station'
    vb.memory = ENV.fetch('EIRINI_STATION_MEMORY', '8192').to_i
    vb.cpus = ENV.fetch('EIRINI_STATION_CPUS', '4').to_i

    # workaround for slow boot (https://bugs.launchpad.net/cloud-images/+bug/1829625)
    vb.customize ["modifyvm", :id, "--uart1", "0x3F8", "4"]
    vb.customize ["modifyvm", :id, "--uartmode1", "file", "./ttyS0.log"]

    override.disksize.size = '50GB'

    override.vm.box = "ubuntu/focal64"

    override.vm.synced_folder "~/.gnupg", "/home/vagrant/.gnupg"
    override.vm.synced_folder "~/.ngrok2", "/home/vagrant/.ngrok2"

    override.vm.network "public_network", bridge: [
      "en0: Wi-Fi (AirPort)",
      "en0: Wi-Fi (Wireless)",
    ]
  end

  config.vm.provider "google" do |gcp, override|
    username = ENV['EIRINI_STATION_USERNAME']

    override.vm.box = "google/gce"

    config.vm.synced_folder ".", "/vagrant", disabled: true
    override.vm.synced_folder "~/.gnupg", "/home/#{username}/.gnupg"

    gcp.google_project_id = 'cf-garden-core'
    gcp.google_json_key_location = ENV['EIRINI_STATION_GCP_JSON_KEY_PATH']
    gcp.image_family = 'ubuntu-2004-lts'
    gcp.machine_type = 'n1-standard-8'
    gcp.disk_size = 50
    gcp.zone = 'europe-west2-a'
    gcp.name = "#{username}-eirini-station"

    override.ssh.username = username
    override.ssh.keys_only = false
  end
end
