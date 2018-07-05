#@summary
#  Install wpcli tool, use it to download wordpress core, create tables in database, configure wordpress and manage plugins and themes.
#
#@example Configure one wordpress instance for URL wordpress.foo.org with remote mariadb database inside an already configurer vhosts root '/var/www/wordpress.foo.org'.
#      class { 'wordpress': 
#        settings => {
#          'wordpress.foo.org' => {
#            owner         => 'wp',
#            dbhost        => 'XX.XX.XX.XX',
#            dbname        => 'wordpress',
#            dbuser        => 'wpuserdb',
#            dbpasswd      => 'kiki',
#            wproot        => '/var/www/wordpress.foo.org',
#            wptitle       => 'hola this wordpress instance is installed by puppet',
#            wpadminuser   => 'wpadmin',
#            wpadminpasswd => 'lolo',
#            wpadminemail  => 'bar@foo.org',
#          }
#        }
#      }
#
#@param settings
#  Describes all availables settings in this module for all wordpress instances on this node. Defaults to empty hash.
#@param wpcli_url
#  http URL where to download the wpcli tool. Default to 'https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar'.
#@param wpcli_bin
#  The PATH where the wpcli tools is deployed. Defaults to '/usr/local/bin/wp'.
#
class wordpress (
  Hash $settings = {},
  Pattern['^http'] $wpcli_url = $wordpress::params::default_wpcli_url,
  Pattern['^/'] $wpcli_bin = $wordpress::params::default_wpcli_bin,
) inherits wordpress::params {

  Exec {
    path        => '/usr/local/sbin:/usr/local/bin:/opt/puppetlabs/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    environment => ['LC_ALL=en_US.utf8','WP_CLI_DISABLE_AUTO_CHECK_UPDATE=yes', ],
  }

  class { 'wordpress::cli' :
    wpcli_url => $wpcli_url,
    wpcli_bin => $wpcli_bin,
  }
  ->
  # install the core of wordpress
  # * download wp
  # * set condifguration settings
  # * connect to db server and create tables
  class { 'wordpress::core' :
    settings  => $settings,
    wpcli_bin => $wpcli_bin,
  }
  ->
  # then manage others resources like plugins and themes
  class { 'wordpress::resource' :
    settings  => $settings,
    wpcli_bin => $wpcli_bin,
  }

  # manage external_fact ll_wordpress
  class { 'wordpress::external_fact' :
    settings => $settings,
  }
  ->
  exec { 'update external fact wordpress':
    command     => '/usr/local/sbin/external_fact_wordpress.rb > /opt/puppetlabs/facter/facts.d/wordpress.yaml',
    user        => 'root',
    refreshonly => true,
  }

}
