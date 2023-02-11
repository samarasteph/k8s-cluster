# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "hashicorp/bionic64"
	config.vm.box = "centos/7"
  #config.vm.box = "generic/alpine312"


  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  config.vm.define :master1 do |master1|
    master1.vm.hostname = "master1"
    master1.vm.provision "shell", inline: <<-SHELL 
      # mkdir ${HOME}/.kube
      # KUB_IP=$(ip -4 -br addr show eth1|sed -r 's/eth1\s+UP\s+([1-9]+\.[0-9]+\.[0-9]+\.[0-9])\/[1-9]+/\1/g')
    SHELL

  end

  config.vm.define :worker1 do |worker1|
    worker1.vm.hostname = "worker1"
    worker1.vm.provision "shell", inline: <<-SHELL
      # KUB_IP=$(ip -4 -br addr show eth1|sed -r 's/eth1\s+UP\s+([1-9]+\.[0-9]+\.[0-9]+\.[0-9])\/[1-9]+/\1/g')
    SHELL
  end

  config.vm.define :worker2 do |worker2|
    worker2.vm.hostname = "worker2"
    worker2.vm.provision "shell", inline: <<-SHELL
      # KUB_IP=$(ip -4 -br addr show eth1|sed -r 's/eth1\s+UP\s+([1-9]+\.[0-9]+\.[0-9]+\.[0-9])\/[1-9]+/\1/g')
    SHELL
  end

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  config.vm.provider "virtualbox" do |vbox, override|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
    vbox.cpus = 2
    vbox.memory = "4096"

    override.vm.network "private_network", type: "dhcp", name: "vboxnet1"
  end

  config.vm.provider "libvirt" do |lbvrt, override|
    lbvrt.cpus = 2 
    lbvrt.memory = "4096"

    override.vm.network "private_network", type: "dhcp", name: "k8s-network"
  end
 
  config.vm.provider "vmware_desktop" do |vwr|
    vwr.vmx["memsize"] = "1024"
    vwr.vmx["numvcpus"] = "2"
  end
  #
  # View the documentation for the provider you are using for more
  # information on available options.

  # Enable provisioning with a shell script. Additional provisioners such as
  # Ansible, Chef, Docker, Puppet and Salt are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL

  config.vm.synced_folder "./", "/home/vagrant/vagrant-host"
  config.vm.provision "shell", path: "./k8s-install.sh"

end
