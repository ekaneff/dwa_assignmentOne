# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  config.vm.box = "ubuntu/xenial64"
  
  config.vm.network "private_network", ip: "172.16.0.15"

  config.vm.provider "virtualbox" do |v|
    v.name = "Wordpress"
    v.customize ["modifyvm", :id, "--memory", "1024"]
  end

  config.vm.provision :shell, path: "bootstrap.sh"

end
