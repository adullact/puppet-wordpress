#@summary Use WP-CLI to download last version of WordPress core, create tables in database and configure WordPress. 
#
#@param wpcli_bin 
#  The PATH where the WP-CLI tools is deployed.
#
#@param settings
#  Describes all availables settings in this module for all wordpress instances on this node. Defaults to empty hash.
#
class wordpress::core (
  Pattern['^/'] $wpcli_bin,
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
      default => $::wordpress::params::default_wpowner,
    }
    $_locale = $_wp_configs['locale'] ? {
      Pattern['^\w\w_\w\w$'] => $_wp_configs['locale'],
      default                => $::wordpress::params::default_locale,
    }
    $_dbprefix = $_wp_configs['dbprefix'] ? {
      Pattern['^\w*$'] => $_wp_configs['dbprefix'],
      default          => $::wordpress::params::default_dbprefix,
    }
    $_wpselfupdate = $_wp_configs['wpselfupdate'] ? {
      Enum['disabled','enabled'] => $_wp_configs['wpselfupdate'],
      default => $::wordpress::params::default_wpselfupdate,
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

        # download wordpress is path defined as wordpress root for the instance ${_wp_servername}

        case $_locale {
          'en_US': {
            exec { "${_wp_servername} > Download core":
              command => "${wpcli_bin} core download",
              cwd     => $_wp_root,
              creates => "${_wp_root}/wp-admin",
              user    => $_owner,
            }
          }
          default: {
            exec { "${_wp_servername} > Download core":
              command => "${wpcli_bin} core download --locale=${_locale}",
              cwd     => $_wp_root,
              creates => "${_wp_root}/wp-admin",
              user    => $_owner,
            }
          }
        }

        # creates the first wp-config.php of the new wordpress installation
        # and then ensure the content stay well configured for the instance ${_wp_servername}

        exec { "${_wp_servername} > Configure core":
          command => "${wpcli_bin} core config --dbhost=${_db_host} --dbname=${_db_name} --dbuser=${_db_user} --dbpass=${_db_passwd} --dbprefix=${_dbprefix} --skip-check --force",
          cwd     => $_wp_root,
          creates => "${_wp_root}/wp-config.php",
          user    => $_owner,
          notify  => Exec['update external fact wordpress'],
        }
        ->
        file_line {"${_wp_servername} > set DB_NAME to ${_db_name}":
          ensure => present,
          path   => "${_wp_root}/wp-config.php",
          line   => "define( 'DB_NAME', '${_db_name}' );",
          match  => '^define\( \'DB_NAME\',',
        }
        ->
        file_line {"${_wp_servername} > set DB_USER to ${_db_user}":
          ensure => present,
          path   => "${_wp_root}/wp-config.php",
          line   => "define( 'DB_USER', '${_db_user}' );",
          match  => '^define\( \'DB_USER\',',
        }
        ->
        file_line {"${_wp_servername} > set DB_PASSWORD":
          ensure => present,
          path   => "${_wp_root}/wp-config.php",
          line   => "define( 'DB_PASSWORD', '${_db_passwd}' );",
          match  => '^define\( \'DB_PASSWORD\',',
        }
        ->
        file_line {"${_wp_servername} > set DB_HOST to ${_db_host}":
          ensure => present,
          path   => "${_wp_root}/wp-config.php",
          line   => "define( 'DB_HOST', '${_db_host}' );",
          match  => '^define\( \'DB_HOST\',',
        }
        ->
        # the database, granted user and credentials must be already created by other process
        # it creates all tables and data structure for the instannce ${_wp_servername}
        exec { "${_wp_servername} > Create core tables":
          command     => "${wpcli_bin} core install --url=${_wp_servername} --title=\"${_wp_title}\" --admin_user=${_wp_admin} --admin_password=${_wp_passwd} --admin_email=${_wp_mail} --skip-email",
          cwd         => $_wp_root,
          user        => $_owner,
          subscribe   => [
            Exec["${_wp_servername} > Configure core"],
            File_line["${_wp_servername} > set DB_NAME to ${_db_name}"],
            File_line["${_wp_servername} > set DB_USER to ${_db_user}"],
            File_line["${_wp_servername} > set DB_PASSWORD"],
            File_line["${_wp_servername} > set DB_HOST to ${_db_host}"],
          ],
          refreshonly => true,
          notify      => Exec['update external fact wordpress'],
        }

        case $_wpselfupdate {
          'enabled': {
            file_line { "${_wp_servername} > set AUTOMATIC_UPDATER_DISABLED to false":
              ensure  => present,
              path    => "${_wp_root}/wp-config.php",
              line    => "define( 'AUTOMATIC_UPDATER_DISABLED', 'false' );",
              match   => '^define\( \'AUTOMATIC_UPDATER_DISABLED\',',
              require => Exec["${_wp_servername} > Configure core"],
            }
          }
          'disabled': {
            file_line { "${_wp_servername} > set AUTOMATIC_UPDATER_DISABLED to true":
              ensure  => present,
              path    => "${_wp_root}/wp-config.php",
              line    => "define( 'AUTOMATIC_UPDATER_DISABLED', 'true' );",
              match   => '^define\( \'AUTOMATIC_UPDATER_DISABLED\',',
              require => Exec["${_wp_servername} > Configure core"],
            }
          }
          default: {
            fail("unexpected value wpselfupdate parameter must be <disabled|enabled>, got '${_wpselfupdate}'")
          }
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

        # four steps :
        # 1. make a backup
        # 2. upgrade core wp
        # 3. upgrade database
        # 4. upgrade language

        $_date = strftime('%Y-%m-%d')

        $_wp_core_update_status = $facts['wordpress']["${_wp_servername}"]['core']['update']
        if $_wp_core_update_status != 'none' {

          # Export and Archive is done as root because of mode 0700 for directory $wordpress_archives 
          file { $::wordpress::params::wordpress_archives :
            ensure => 'directory',
            mode   => '0700',
            owner  => 0,
            group  => 0,
          }
          ->
          exec { "${_wp_servername} > Export database before upgrade" :
            command => "${wpcli_bin} --allow-root --path=${_wp_root} db export",
            cwd     => $::wordpress::params::wordpress_archives,
            creates => "${wordpress::params::wordpress_archives}/${_wp_servername}_${_date}.tar.gz",
          }
          ->
          exec { "${_wp_servername} > Archive files before upgrade" :
            command => "tar -cvf ${wordpress::params::wordpress_archives}/${_wp_servername}_${_date}.tar.gz .",
            cwd     => $_wp_root,
            creates => "${wordpress::params::wordpress_archives}/${_wp_servername}_${_date}.tar.gz",
          }

          case $_locale {
            'en_US': {
              exec { "${_wp_servername} > Upgrade core wordpress" :
                command => "${wpcli_bin} --path=${_wp_root} core update",
                user    => $_owner,
                require => Exec["${_wp_servername} > Archive files before upgrade"],
              }
            }
            default: {
              exec { "${_wp_servername} > Upgrade core wordpress" :
                command => "${wpcli_bin} --path=${_wp_root} core update --locale=${_locale}",
                user    => $_owner,
                require => Exec["${_wp_servername} > Archive files before upgrade"],
              }
            }
          }
          exec { "${_wp_servername} > Upgrade database structure" :
            command => "${wpcli_bin} --path=${_wp_root} core update-db",
            user    => $_owner,
            require => Exec["${_wp_servername} > Upgrade core wordpress"],
            notify  => Exec['update external fact wordpress'],
          }

        }

        $_wp_language_update_status =  $facts['wordpress']["${_wp_servername}"]['language']['update']
        if $_wp_language_update_status != 'none' {
          exec { "${_wp_servername} > Update language" :
            command => "${wpcli_bin} --path=${_wp_root} language core update",
            user    => $_owner,
            require => Exec["${_wp_servername} > Update core wordpress"],
            notify  => Exec['update external fact wordpress'],
          }
        }
      }
      default: {
        fail("unexpected value ensure parameter must be <present|absent|latest>, got '${_ensure}'")
      }
    }

  }

}

