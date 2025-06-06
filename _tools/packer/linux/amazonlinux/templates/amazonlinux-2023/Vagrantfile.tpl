Vagrant.configure("2") do |config|
  config.vm.define "source", autostart: false do |source|
	  source.vm.box = "bento/amazonlinux-2023"
	  config.ssh.insert_key = false
  end
  config.vm.define "output" do |output|
	  output.vm.box = "amazonlinux-2023"
	  output.vm.box_url = "file://package.box"
	  config.ssh.insert_key = false
  end
  config.vm.provider :virtualbox do |vb|
    vb.memory = 1024
    vb.cpus = 2
    vb.customize [ "modifyvm", :id, "--uartmode1", "disconnected" ]
  end
  config.vm.synced_folder ".", "/vagrant", disabled: true
end
