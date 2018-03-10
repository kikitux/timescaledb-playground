Vagrant.configure("2") do |config|
  config.vm.box = "cbednarski/ubuntu-1604"
  config.vm.define "timescaledb" do |timescaledb|
    timescaledb.vm.hostname = "timescaledb"
    timescaledb.vm.provider "virtualbox" do |v|
      v.memory = 3333
      v.cpus = 2
    end
    timescaledb.vm.provision "shell", path: "provision/script.sh"
    timescaledb.vm.provision "shell", path: "provision/statsite.sh"
  end

  (1..2).each do |i|
    config.vm.define vm_name = "node#{i}" do |node|
      node.vm.hostname = vm_name
    end
  end

end
