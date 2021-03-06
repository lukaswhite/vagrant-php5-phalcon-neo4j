# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

# Require the reboot plugin.
require './provision/vagrant-provision-reboot-plugin'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Base Box
  # --------------------
  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  # Connect to IP
  # Note: Use an IP that doesn't conflict with any OS's DHCP (Below is a safe bet)
  # --------------------
  config.vm.network :private_network, ip: "192.168.50.4"

  # Forward to Port
  # --------------------
  #config.vm.network :forwarded_port, guest: 80, host: 8080
  # config.vm.network :forwarded_port, guest: 7474, host: 7575

  # Optional (Remove if desired)
  config.vm.provider :virtualbox do |v|
    # How much RAM to give the VM (in MB)
    # -----------------------------------
    v.customize ["modifyvm", :id, "--memory", "2048"]

    # Uncomment the Bottom two lines to enable muli-core in the VM
    #v.customize ["modifyvm", :id, "--cpus", "2"]
    #v.customize ["modifyvm", :id, "--ioapic", "on"]
  end

  # Provisioning Script
  # --------------------
  config.vm.provision "shell", path: "./provision/init.sh"

  # Synced Folder
  # --------------------
  config.vm.synced_folder ".", "/vagrant/", :mount_options => [ "dmode=777", "fmode=666" ]
  config.vm.synced_folder "./www", "/vagrant/www/", :mount_options => [ "dmode=775", "fmode=644" ], :owner => 'www-data', :group => 'www-data'

  # Reboot the virtual machine, required for post-Neo4j installation tweaks to open files etc
  # --------------------
  config.vm.provision :unix_reboot

end
