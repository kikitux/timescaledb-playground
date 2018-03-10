Vagrant.configure("2") do |config|
  config.vm.box = "cbednarski/ubuntu-1604"
  config.vm.define vm_name = "timescaledb" do |timescaledb|
    timescaledb.vm.hostname = vm_name
    timescaledb.vm.provider "virtualbox" do |v|
      v.memory = 3333
      v.cpus = 2
    end
    timescaledb.vm.provision "shell", path: "provision/script.sh"
    timescaledb.vm.provision "shell", path: "provision/statsite.sh"
  end

  (1..2).each do |i|
    vm_name = "node#{i}"
    config.vm.define vm_name do |node|
    end
  end

end
