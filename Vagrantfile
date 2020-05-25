Vagrant.configure("2") do |config|
  config.vm.box = "alvaro/bionic64"
  config.vm.define "timescaledb" do |timescaledb|
    timescaledb.vm.hostname = "timescaledb"
    timescaledb.vm.provider "virtualbox" do |v|
      v.memory = 3333
      v.cpus = 2
    end
    timescaledb.vm.provision "shell", path: "scripts/timescaledb.sh"
    timescaledb.vm.provision "shell", path: "scripts/statsite.sh"
  end

  #(1..2).each do |i|
  #  config.vm.define vm_name = "node#{i}" do |node|
  #    node.vm.provider "virtualbox"
  #    node.vm.hostname = vm_name
  #  end
  #end

end
