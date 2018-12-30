#@summary Use WP-CLI to download last version of WordPress core, create tables in database and configure WordPress. 
#
#@param wpcli_bin 
#  The PATH where the WP-CLI tools is deployed.
#
#@param wparchives_path
#  Gives the path where are stored archives done before update managed by puppet (not by WordPress itself with `wpselfupdate`). Defaults to /var/wordpress_archives.
#
#@param settings
#  Describes all availables settings in this module for all wordpress instances on this node. Defaults to empty hash.
#
#@note This class should be considered as private.
class wordpress::core (
  Pattern['^/'] $wpcli_bin,
  Pattern['^/'] $wparchives_path,
  Wordpress::Settings $settings = {},
) {

  $settings.each | String $_wp_servername , Hash $_wp_configs | {

    # use some defaults if not provided
    $_ensure = $_wp_configs['ensure'] ? {
      Enum['present','absent','latest'] => $_wp_configs['ensure'],
      default => 'present',
    }
    $_owner = $_wp_configs['owner'] ? {
      String  => $_wp_configs['owner'],
      default => $wordpress::params::default_wpowner,
    }
    $_locale = $_wp_configs['locale'] ? {
      Pattern['^\w\w_\w\w$'] => $_wp_configs['locale'],
      default                => $wordpress::params::default_locale,
    }
    $_dbprefix = $_wp_configs['dbprefix'] ? {
      Pattern['^\w*$'] => $_wp_configs['dbprefix'],
      default          => $wordpress::params::default_dbprefix,
    }
    $_wpselfupdate = $_wp_configs['wpselfupdate'] ? {
      Enum['disabled','enabled'] => $_wp_configs['wpselfupdate'],
      default => $wordpress::params::default_wpselfupdate,
    }

    $_wp_root = $_wp_configs['wproot']
    $_wp_title = $_wp_configs['wptitle']
    $_wp_admin = $_wp_configs['wpadminuser']
    $_wp_passwd = $_wp_configs['wpadminpasswd']
    $_wp_mail = $_wp_configs['wpadminemail']
    $_db_host = $_wp_configs['dbhost']
    $_db_name = $_wp_configs['dbname']
    $_db_user = $_wp_configs['dbuser']
    $_db_passwd = $_wp_configs['dbpasswd']

    case $_ensure {
      'present': {
        wordpress::core::install { $_wp_servername :
          wp_servername => $_wp_servername,
          wp_root       => $_wp_root,
          owner         => $_owner,
          locale        => $_locale,
          db_host       => $_db_host,
          db_name       => $_db_name,
          db_user       => $_db_user,
          db_passwd     => $_db_passwd,
          dbprefix      => $_dbprefix,
          wp_title      => $_wp_title,
          wp_admin      => $_wp_admin,
          wp_passwd     => $_wp_passwd,
          wp_mail       => $_wp_mail,
          wpselfupdate  => $_wpselfupdate,
          wpcli_bin     => $wpcli_bin,
        }

        wordpress::core::config { $_wp_servername :
          wp_servername => $_wp_servername,
          wp_root       => $_wp_root,
          owner         => $_owner,
          locale        => $_locale,
          db_host       => $_db_host,
          db_name       => $_db_name,
          db_user       => $_db_user,
          db_passwd     => $_db_passwd,
          dbprefix      => $_dbprefix,
          wp_title      => $_wp_title,
          wp_admin      => $_wp_admin,
          wp_passwd     => $_wp_passwd,
          wp_mail       => $_wp_mail,
          wpselfupdate  => $_wpselfupdate,
          wpcli_bin     => $wpcli_bin,
        }

      }
      'absent': {

        # Ensure that setting wproot is realy a path and not empty
        # elsewhere it will make rm -Rf /* ...
        # The atttribute onlyif should be enougth to not run a killer command.
        # The function assert_type raise error and stop the run.

        $_real_wproot = assert_type(Pattern[/^\/\w*\//], $_wp_root)
        exec { "${_wp_servername} > Erase wordpress":
          command => "rm -Rf ${_real_wproot}/*",
          onlyif  => "test -f ${_real_wproot}/wp-config.php",
          notify  => Exec['update external fact wordpress'],
        }
      }
      'latest': {
        file { $wparchives_path :
          ensure => 'directory',
          mode   => '0700',
          owner  => 0,
          group  => 0,
        }

        if $facts['wordpress'] and
        has_key($facts['wordpress'], $_wp_servername) and
        has_key($facts['wordpress']["${_wp_servername}"], 'core') and
        has_key($facts['wordpress']["${_wp_servername}"]['core'], 'update') {
          $_wp_core_update_status = $facts['wordpress']["${_wp_servername}"]['core']['update']
          if $_wp_core_update_status != 'none' {
            wordpress::core::update { $_wp_servername :
              wp_servername   => $_wp_servername,
              wp_root         => $_wp_root,
              owner           => $_owner,
              locale          => $_locale,
              wpselfupdate    => $_wpselfupdate,
              wpcli_bin       => $wpcli_bin,
              wparchives_path => $wparchives_path,
              require         => File[$wparchives_path],
            }
          }
        } else {
          wordpress::core::install { $_wp_servername :
            wp_servername => $_wp_servername,
            wp_root       => $_wp_root,
            owner         => $_owner,
            locale        => $_locale,
            db_host       => $_db_host,
            db_name       => $_db_name,
            db_user       => $_db_user,
            db_passwd     => $_db_passwd,
            dbprefix      => $_dbprefix,
            wp_title      => $_wp_title,
            wp_admin      => $_wp_admin,
            wp_passwd     => $_wp_passwd,
            wp_mail       => $_wp_mail,
            wpselfupdate  => $_wpselfupdate,
            wpcli_bin     => $wpcli_bin,
          }

          wordpress::core::config { $_wp_servername :
            wp_servername => $_wp_servername,
            wp_root       => $_wp_root,
            owner         => $_owner,
            locale        => $_locale,
            db_host       => $_db_host,
            db_name       => $_db_name,
            db_user       => $_db_user,
            db_passwd     => $_db_passwd,
            dbprefix      => $_dbprefix,
            wp_title      => $_wp_title,
            wp_admin      => $_wp_admin,
            wp_passwd     => $_wp_passwd,
            wp_mail       => $_wp_mail,
            wpselfupdate  => $_wpselfupdate,
            wpcli_bin     => $wpcli_bin,
          }
          ->
          wordpress::core::update { $_wp_servername :
            wp_servername   => $_wp_servername,
            wp_root         => $_wp_root,
            owner           => $_owner,
            locale          => $_locale,
            wpselfupdate    => $_wpselfupdate,
            wpcli_bin       => $wpcli_bin,
            wparchives_path => $wparchives_path,
            require         => File[$wparchives_path],
          }
        }
      }
      default: {
        fail("unexpected value ensure parameter must be <present|absent|latest>, got '${_ensure}'")
      }
    }

  }

}

