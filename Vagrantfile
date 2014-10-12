# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
 config.vm.box = "chef/centos-6.5"
    config.vm.box_url = "https://vagrantcloud.com/chef/centos-6.5/version/1/provider/virtualbox.box"

    config.vm.provider "virtualbox" do |vb|
      # Sets the available memory to 1GB
      vb.customize ["modifyvm", :id, "--memory", 1024, "--cpus", "2"]
    end


    # Switching to nfs for only those who want it, to add more, it is space separated
    nfs_hosts=%w(nsmith13-mbp dhcp-10-40-26-255)

    require 'socket'
    my_hostname=Socket.gethostname.split(/\./)[0]

    if nfs_hosts.include?(my_hostname)
          # Assign this VM to a host only network IP, allowing you to access it
          # via the IP.
          config.vm.network "private_network", ip: "192.168.56.123"
          #config.vm.network :hostonly, "192.168.123.123"
          config.vm.synced_folder ".", "/vagrant", type: "nfs"
    else
          config.vm.synced_folder ".", "/vagrant"
    end


  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.network "forwarded_port", guest: 8889, host: 8889
  config.vm.network "forwarded_port", guest: 8890, host: 8890

  config.vm.provision "ansible" do |ansible|
      ansible.playbook = "ansible/server.yml"
      ansible.verbose = 'vv'
  end

end
