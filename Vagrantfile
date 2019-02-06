# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.require_version ">= 1.8.4"

Vagrant.configure(2) do |config|
  config.vm.box = 'ubuntu/xenial64'
  config.vm.box_check_update = false
  config.vm.hostname = 'vagrant-devstack'
  config.vm.network :private_network, ip: '192.168.50.50'
  config.vm.network :forwarded_port, guest: 80, host: 8080
  config.vm.network :forwarded_port, guest: 5000, host: 5000

  config.vm.provider 'virtualbox' do |v|
#    v.customize ["modifyvm", :id, "--natnet1", "192.168.122.0/27"]
    v.customize ['modifyvm', :id, '--memory', 1024 * 6 ]
    v.customize ["modifyvm", :id, "--cpus", 2]
  end

  if ENV['http_proxy'] != nil and ENV['https_proxy'] != nil and ENV['no_proxy'] != nil
    if not Vagrant.has_plugin?('vagrant-proxyconf')
      system 'vagrant plugin install vagrant-proxyconf'
      raise 'vagrant-proxyconf was installed but it requires to execute again'
    end
    config.proxy.http     = ENV['http_proxy']
    config.proxy.https    = ENV['https_proxy']
    config.proxy.no_proxy = ENV['no_proxy']
  end

  config.vm.provision 'shell' do |s|
    s.path = 'install_devstack.sh'
    s.args = ['--basic']
    s.privileged  = false
  end

end

