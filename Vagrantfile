Vagrant.configure("2") do |config|
  config.vm.hostname = "#{`hostname`[0..-2]}-eirini"
  config.ssh.forward_agent = true

  config.vm.provision "shell", path: "provision.sh"
  config.vm.provision "shell" do |p|
    p.path = "provision-user.sh"
    p.privileged = false
  end

  home = ENV['HOME']
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

    gcp.google_project_id = 'cff-eirini-peace-pods'
    gcp.google_json_key_location = ENV['EIRINI_STATION_GCP_JSON_KEY_PATH']
    gcp.image_family = 'ubuntu-2004-lts'
    gcp.machine_type = 'n1-standard-8'
    gcp.disk_size = 100
    gcp.disk_type = "pd-ssd"
    gcp.zone = 'europe-west2-a'
    gcp.name = "#{username}-eirini-station"

    override.ssh.username = username
    override.ssh.keys_only = false
    override.ssh.extra_args = ["-R", "/home/#{username}/.gnupg/S.gpg-agent-#{username}:#{home}/.gnupg/S.gpg-agent.extra"]
  end
end

class SetHostTimezonePlugin < Vagrant.plugin('2')
  class SetHostTimezoneAction
    def initialize(app, env)
      @app = app
    end

    def call(env)
      @app.call(env)

      machine = env[:machine]

      if machine.guest.capability?(:change_timezone)
        timezone =`cat /etc/timezone 2>/dev/null`.strip
        if $?.exitstatus != 0
          timezone = nil
          if Vagrant::Util::Platform.darwin?
            puts "🙄 It looks like you are a Mac user, let me try to figure your timezone out...."
            timezone=`realpath --relative-to=/var/db/timezone/zoneinfo $(readlink /etc/localtime)`.strip

            if $?.exitstatus != 0
              puts "🤬 I might need to sudo to get your timezone, can you believe that!?"
              timezone =`sudo systemsetup -gettimezone | awk '{ print $3 }'`.strip
            end
          end

          if timezone.nil? || timezone.empty?
            # Thanks to https://stackoverflow.com/a/46778032
            puts "🙁 Alas, human, I did my best to figure out your timezone, but I failed!\nFalling back to timezone offset...\n"
            offset = ((Time.zone_offset(Time.now.zone) / 60) / 60)
            timezone_suffix = offset >= 0 ? "-#{offset.to_s}" : "+#{offset.to_s}"
            timezone = 'Etc/GMT' + timezone_suffix
          end
        end
        puts "🌐 Setting timezone to " + timezone + "...\n"
        machine.guest.capability(:change_timezone, timezone)
      else
        puts "🤔 Hmmmm, it seems the guest VM does not support the change_timezone capability..."
      end

    end
  end

  name 'set-host-timezone'

  action_hook 'set-host-timezone' do |hook|
    hook.before Vagrant::Action::Builtin::Provision, SetHostTimezoneAction
  end
end
