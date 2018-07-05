require 'beaker-rspec'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'

run_puppet_install_helper unless ENV['BEAKER_provision'] == 'no'
install_module_on(hosts)
install_module_dependencies_on(hosts)

RSpec.configure do |c|
  # Configure all nodes in nodeset
  c.before :suite do

    #we need :
    # * a mariadb server with database and granted user
    # * an apache webserver
    # * a dedicated account
    # * a php with mysql driver

    hosts.each do |host|
      on host, puppet('module', 'install', 'puppetlabs-accounts')
      on host, puppet('module', 'install', 'puppetlabs-mysql')
      on host, puppet('module', 'install', 'puppetlabs-apache')
      on host, puppet('module', 'install', 'puppet-archive')

      if host[:platform] =~ %r{debian-8-amd64}
        on(host, 'apt-get update', acceptable_exit_codes: [0]).stdout
        on(host, 'apt install php5-cli php5-mysql', acceptable_exit_codes: [0]).stdout
        # workaround the apache moduel try to install the following debs and fail.
        on(host, 'apt install libapache2-mod-php5 apache2-mpm-itk --yes', acceptable_exit_codes: [0]).stdout
        # curl is used in tests to access at a wordpress newly installed
        on(host, 'apt install curl --yes', acceptable_exit_codes: [0]).stdout
      elsif host[:platform] =~ %r{el-7-x86_64}
        # apache mpm itk is provided by EPEL
        on(host, 'yum install epel-release -y', acceptable_exit_codes: [0]).stdout
        on(host, 'yum makecache', acceptable_exit_codes: [0]).stdout
        on(host, 'yum install php-cli.x86_64 php-mysql.x86_64 -y', acceptable_exit_codes: [0]).stdout
        # curl is used in tests to access at a wordpress newly installed
        on(host, 'yum install curl.x86_64 -y', acceptable_exit_codes: [0]).stdout
      elsif host[:platform] =~ %r{ubuntu-16.04-amd64}
        on(host, 'apt-get update', acceptable_exit_codes: [0]).stdout
        on(host, 'apt install php7.0-cli php7.0-mysql --yes', acceptable_exit_codes: [0]).stdout
        # curl is used in tests to access at a wordpress newly installed
        on(host, 'apt install curl --yes', acceptable_exit_codes: [0]).stdout
      else
      end
    end

    pp = <<-EOS
    include '::mysql::server'
    
    accounts::user { 'wp' : }
    
    class { 'apache':
      default_vhost => false,
      mpm_module    => 'itk',
      default_mods  => ['php','rewrite'],
    }
    
    apache::vhost {'wordpress.foo.org':
      servername => 'wordpress.foo.org',
      ip => '127.0.0.1',
      port => 80,
      docroot => '/var/www/wordpress.foo.org',
      docroot_owner => 'wp',
      docroot_group => 'wp',
      docroot_mode => '0750',
      itk => {
        user => 'wp',
        group => 'wp',
      },
      directories => {
        path           => '/var/www/wordpress.foo.org', 
        allow_override => 'All' 
      },
      require => Accounts::User['wp'],
    }
    
    class {'::mysql::bindings':
      java_enable   => false,
      perl_enable   => false,
      php_enable    => true,
      python_enable => false,
      ruby_enable   => false,
    }
    
    mysql::db { 'wordpress':
      user     => 'wpuserdb',
      password => 'kiki',
      host     => 'localhost',
      grant    => ['ALL'],
    }
    EOS

    apply_manifest_on(agents, pp, catch_failures: true)
  end
end

shared_examples 'a idempotent resource' do
  it 'applies with no errors' do
    apply_manifest(pp, catch_failures: true)
  end

  it 'applies a second time without changes' do
    apply_manifest(pp, catch_changes: true)
  end
end
