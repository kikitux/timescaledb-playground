Vagrant.configure("2") do |config|
  config.vm.box = "cbednarski/ubuntu-1604"
  config.vm.hostname = "timescaledb"
  config.vm.provider "virtualbox" do |v|
    v.memory = 3333
    v.cpus = 2
  end
  config.vm.provision "shell", path: "provision/script.sh"
  config.vm.provision "shell", path: "provision/statsite.sh"
end
