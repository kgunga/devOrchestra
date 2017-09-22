# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "ubuntu/trusty64"
  # DevOrchestra Back-End
  config.vm.network "forwarded_port", guest: 8400, host: 8400
  # DevOrchestra UI
  config.vm.network "forwarded_port", guest: 3000, host: 3000
  # DevOrchestra Web-Terminal
  config.vm.network "forwarded_port", guest: 8401, host: 8401

  # List here you projects' needed ports

  config.vm.synced_folder "./src/frontend", "/home/vagrant/devOrchestra/frontend", id: "frontend",
                    type: "rsync" ,
                    rsync__exclude: [".git/","node_modules/","dist/"],
                    rsync__auto: true
                            #, rsync__args: ["-r","-u", "--delete"]

  config.vm.synced_folder "./src/backend", "/home/vagrant/devOrchestra/backend", id: "backend",
                      type: "rsync" ,
                      rsync__exclude: [".git/","node_modules/","dist/"],
                      rsync__auto: true
                              #, rsync__args: ["-r","-u", "--delete"]

  config.vm.provider "virtualbox" do |vb|
    vb.name = "DevOrchestra - Ubuntu"
    # Display the VirtualBox GUI when booting the machine
    vb.gui = false
  
    # Customize the amount of memory on the VM:
    vb.memory = "2048"
  end

  config.vm.provision "puppet" do |puppet|
    puppet.manifests_path = "puppet/manifests"
    puppet.manifest_file = "init.pp"
    puppet.module_path = "puppet/modules"
  end
end
