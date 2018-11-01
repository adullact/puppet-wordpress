require 'beaker-rspec'
require 'beaker-puppet'
require 'beaker/puppet_install_helper'
require 'beaker/module_install_helper'

run_puppet_install_helper unless ENV['BEAKER_provision'] == 'no'
install_module_on(hosts)
install_module_dependencies_on(hosts)

RSpec.configure do |c|
  # Configure all nodes in nodeset
  c.before :suite do
    # we need :
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
        # workaround the apache module try to install the following apache debs and fail.
        # curl is used in tests to access at a wordpress newly installed
        on(host, 'apt-get update', acceptable_exit_codes: [0]).stdout
        on(host, 'apt install php5-cli php5-mysql --yes', acceptable_exit_codes: [0]).stdout
        on(host, 'apt install curl libapache2-mod-php5 apache2-mpm-itk --yes', acceptable_exit_codes: [0]).stdout
      elsif host[:platform] =~ %r{el-7-x86_64}
        # apache mpm itk is provided by EPEL
        # curl is used in tests to access at a wordpress newly installed
        on(host, 'yum install epel-release -y', acceptable_exit_codes: [0]).stdout
        on(host, 'yum makecache', acceptable_exit_codes: [0]).stdout
        on(host, 'yum install curl.x86_64 php-cli.x86_64 php-mysql.x86_64 -y', acceptable_exit_codes: [0]).stdout
      elsif host[:platform] =~ %r{ubuntu-16.04-amd64}
        on(host, 'apt-get update', acceptable_exit_codes: [0]).stdout
        # curl is used in tests to access at a wordpress newly installed
        # cron package is not install on docker image
        on(host, 'apt install cron curl php7.0-cli php7.0-mysql --yes', acceptable_exit_codes: [0]).stdout
      end
    end

    pp = <<-EOS
    include '::mysql::server'

    $myfqdn = 'localhost'
    accounts::user { 'wp' : }
    accounts::user { 'wp2' : }
    accounts::user { 'wp3' : }

    class { 'apache':
      default_vhost => false,
      mpm_module    => 'itk',
      default_mods  => ['php','rewrite'],
    }

    apache::vhost { $myfqdn :
      servername => $myfqdn,
      ip => '127.0.0.1',
      port => 80,
      docroot => "/var/www/${myfqdn}",
      docroot_owner => 'wp',
      docroot_group => 'wp',
      docroot_mode => '0750',
      itk => {
        user => 'wp',
        group => 'wp',
      },
      directories => {
        path           => "/var/www/${myfqdn}",
        allow_override => 'All'
      },
      require => Accounts::User['wp'],
    }
    apache::vhost {'wp2.foo.org':
      servername => 'wp2.foo.org',
      ip => '127.0.0.1',
      port => 80,
      docroot => '/var/www/wp2.foo.org',
      docroot_owner => 'wp2',
      docroot_group => 'wp2',
      docroot_mode => '0750',
      itk => {
        user => 'wp2',
        group => 'wp2',
      },
      directories => {
        path           => '/var/www/wp2.foo.org',
        allow_override => 'All'
      },
      require => Accounts::User['wp2'],
    }
    apache::vhost {'wp3.foo.org':
      servername => 'wp3.foo.org',
      ip => '127.0.0.1',
      port => 80,
      docroot => '/var/www/wp3.foo.org',
      docroot_owner => 'wp3',
      docroot_group => 'wp3',
      docroot_mode => '0750',
      itk => {
        user => 'wp3',
        group => 'wp3',
      },
      directories => {
        path           => '/var/www/wp3.foo.org',
        allow_override => 'All'
      },
      require => Accounts::User['wp3'],
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
    mysql::db { 'wordpress2':
      user     => 'wp2userdb',
      password => 'kiki',
      host     => 'localhost',
      grant    => ['ALL'],
    }
    mysql::db { 'wordpress3':
      user     => 'wp3userdb',
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
