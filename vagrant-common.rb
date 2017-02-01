VAGRANT_IMAGE = 'bento/ubuntu-16.04'
VAGRANTFILE_API_VERSION = '2'

def get_go_version_from_build_dockerfile()
  go_regexp = /FROM golang:(\S*).*?/
  dockerfile_path = File.expand_path(File.join(File.dirname(__FILE__), 'build', 'Dockerfile'))
  go_version = File.readlines(dockerfile_path).first { |line| line.match(go_regexp) }.match(go_regexp).captures.first
  if go_version.nil?
    raise ArgumentError.new("Failed to read Go version from Dockerfile.")
  end
  go_version
end

GO_VERSION = get_go_version_from_build_dockerfile()

def configure_nat_dns(vb)
  vb.customize ["modifyvm", :id, "--natdnshostresolver1", "off"]
  vb.customize ["modifyvm", :id, "--natdnsproxy1", "off"]
end

def cleanup(vm)
  vm.provision :shell, :inline => <<SCRIPT
export DEBIAN_FRONTEND=noninteractive
## Who the hell thinks official images have to have both of these?
[ ! -f /etc/init.d/chef-client ] || /etc/init.d/chef-client stop
[ ! -f /etc/init.d/puppet ]      || /etc/init.d/puppet stop
apt-get -qq remove puppet chef
apt-get -qq autoremove
killall -9 chef-client 2>/dev/null || true
SCRIPT
end
