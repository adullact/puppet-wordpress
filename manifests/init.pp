#@summary
#  Install WP-CLI tool, use it to download wordpress core, create tables in database, configure WordPress and manage plugins and themes.
#
#@example 
#  Configure one WordPress instance for URL wordpress.foo.org by using already existing database server and database account and web server with vhost root '/var/www/wordpress.foo.org'.
#
#    class { 'wordpress': 
#      settings => {
#        'wordpress.foo.org' => {
#          owner         => 'wp',
#          dbhost        => 'XX.XX.XX.XX',
#          dbname        => 'wordpress',
#          dbuser        => 'wpuserdb',
#          dbpasswd      => 'kiki',
#          wproot        => '/var/www/wordpress.foo.org',
#          wptitle       => 'hola this wordpress instance is installed by puppet',
#          wpadminuser   => 'wpadmin',
#          wpadminpasswd => 'lolo',
#          wpadminemail  => 'bar@foo.org',
#        }
#      }
#    }
#
#  Bellow the datatype of `$settings`. Parameters without a default value are mandatory unless otherwise stated.
#
#    Hash[
#      String,                  # The URI of the WordPress instance (like : www.foo.org).
#      Hash[
#        Enum[
#          'ensure',            # Possible values : present, absent, lastest (defaults present).
#          'wproot',            # Path where is located root of WordPress instance. 
#          'owner',             # User that own files of WordPress instance.
#          'locale',            # Language used by WordPress instance (defaults en_US).
#          'dbhost',            # Address of the database server (must be MySQL or MariaDB).
#          'dbname',            # Name of the database where tables of WordPress instance are stored.
#          'dbuser',            # User of the database used by wordpress to connect to the database server.
#          'dbpasswd',          # Password of the user of the database.
#          'dbprefix',          # Set table prefix (defaults wp<random_number_with_4_digits>).
#          'wpselfupdate',      # Possible values : disabled , enabled (defaults disabled).
#          'wptitle',           # Init title of the WordPress instance.
#          'wpadminuser',       # Name of admin account of the WordPress instance.
#          'wpadminpasswd',     # Password of the admin account of the WordPress instance.
#          'wpadminemail',      # email address of the admin account.
#          'wpresources',       # Settings for plugins and themes (not mandatory).
#        ],
#        Variant[
#          String,
#          Hash[
#            Enum[
#              'plugin',
#              'theme',
#            ],
#            Array[
#              Hash[
#                Enum[
#                  'name',      # Name of the plugin or theme
#                  'ensure',    # Possible values : present, absent, latest (defaults present).
#                ],
#                String
#                ]
#              ]
#            ]
#          ]
#        ]
#      ]
#  
#
#@param settings
#  Describes all availables settings in this module for all wordpress instances on this node. Defaults to empty hash.
#
#@param wparchives_path
#  Gives the path where are stored archives done before update managed by puppet (not by WordPress itself with `wpselfupdate`). Defaults to /var/wordpress_archives.
#
#@param wpcli_url
#  Gives the address from which to download the WP-CLI tool. Defaults to 'https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar'.
#
#@param wpcli_bin
#  Gives the path where the WP-CLI tools is deployed. Defaults to '/usr/local/bin/wp'.
#
#@param hour_fact_update
#  Gives the time (hour between 1 and 23) at which the update of external fact is done. Defaults to 7.
#
class wordpress (
  Hash $settings = {},
  Pattern['^/'] $wparchives_path = $wordpress::params::default_wparchives_path,
  Pattern['^http'] $wpcli_url = $wordpress::params::default_wpcli_url,
  Pattern['^/'] $wpcli_bin = $wordpress::params::default_wpcli_bin,
  Integer[1,23] $hour_fact_update = $wordpress::params::default_hour_fact_update,
) inherits wordpress::params {

  Exec {
    path        => '/usr/local/sbin:/usr/local/bin:/opt/puppetlabs/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    environment => ['LC_ALL=en_US.utf8','WP_CLI_DISABLE_AUTO_CHECK_UPDATE=yes', ],
  }

  class { 'wordpress::cli' :
    wpcli_url => $wpcli_url,
    wpcli_bin => $wpcli_bin,
  }
  # install the core of wordpress
  # * download wp
  # * set condifguration settings
  # * connect to db server and create tables
  -> class { 'wordpress::core' :
    settings        => $settings,
    wpcli_bin       => $wpcli_bin,
    wparchives_path => $wparchives_path,
    require         => [
      Class[wordpress::cli],
    ],
  }

  # then manage others resources like plugins and themes
  class { 'wordpress::resource' :
    settings  => $settings,
    wpcli_bin => $wpcli_bin,
    require   => [
      Class[wordpress::cli],
      Class[wordpress::core],
    ],
  }

  # and finaly set options of sites
  class { 'wordpress::site' :
    settings  => $settings,
    wpcli_bin => $wpcli_bin,
    require   => [
      Class[wordpress::cli],
      Class[wordpress::core],
      Class[wordpress::resource],
    ],
  }

  # manage external_fact wordpress
  class { 'wordpress::external_fact' :
    settings         => $settings,
    hour_fact_update => $hour_fact_update,
  }

}
