#@summary configure WordPress instance.
#
#@param wp_servername
#  The URI of the WordPress instance (like : www.foo.org).
#@param wp_root
#  The root path of the WordPress instance.
#@param owner
#  The OS account, owner of files of the WordPress instance.
#@param locale
#  Language used by WordPress instance (defaults en_US).
#@param db_host
#  Address of the database server (must be MySQL or MariaDB).
#@param db_name
#  Name of the database where tables of WordPress instance are stored.
#@param db_user
#  User of the database used by wordpress to connect to the database server.
#@param db_passwd
#  Password of the user of the database.
#@param dbprefix
#  Set table prefix (defaults wp<random_number_with_4_digits>).
#@param wp_title
#  Init title of the WordPress instance.
#@param wp_admin
#  Name of admin account of the WordPress instance.
#@param wp_passwd
#  Password of the admin account of the WordPress instance.
#@param wp_mail
#  Email address of the admin account.
#@param wpselfupdate
#  Possible values : disabled , enabled (defaults disabled).
#@param wpcli_bin
#  The path of the WP-CLI tool.
#
#@api private
#
define wordpress::core::config (
  String $wp_servername,
  String $wp_root,
  String $owner,
  String $locale,
  String $db_host,
  String $db_name,
  String $db_user,
  String $db_passwd,
  String $dbprefix,
  String $wp_title,
  String $wp_admin,
  String $wp_passwd,
  String $wp_mail,
  String $wpselfupdate,
  String $wpcli_bin,
) {
  assert_private()
  # ensure the content stay well configured for the instance ${wp_servername}

  exec {"${wp_servername} > set DB_NAME to ${db_name}":
    command => "${wpcli_bin} config set DB_NAME ${db_name}",
    onlyif  => "${wpcli_bin} config get DB_NAME | grep -qv '${db_name}'",
    cwd     => $wp_root,
    user    => $owner,
    require => Exec["${wp_servername} > Create wp-config.php"],
  }

  exec {"${wp_servername} > set DB_USER to ${db_user}":
    command => "${wpcli_bin} config set DB_USER ${db_user}",
    onlyif  => "${wpcli_bin} config get DB_USER | grep -qv '${db_user}'",
    cwd     => $wp_root,
    user    => $owner,
    require => Exec["${wp_servername} > Create wp-config.php"],
  }

  exec {"${wp_servername} > set DB_PASSWORD":
    command => "${wpcli_bin} config set DB_PASSWORD ${db_passwd}",
    onlyif  => "${wpcli_bin} config get DB_PASSWORD | grep -qv '${db_passwd}'",
    cwd     => $wp_root,
    user    => $owner,
    require => Exec["${wp_servername} > Create wp-config.php"],
  }

  exec {"${wp_servername} > set DB_HOST to ${db_host}":
    command => "${wpcli_bin} config set DB_HOST ${db_host}",
    onlyif  => "${wpcli_bin} config get DB_HOST | grep -qv '${db_host}'",
    cwd     => $wp_root,
    user    => $owner,
    require => Exec["${wp_servername} > Create wp-config.php"],
  }

  case $wpselfupdate {
    'enabled': {
      exec { "${wp_servername} > set AUTOMATIC_UPDATER_DISABLED to false":
        command => "${wpcli_bin} config set AUTOMATIC_UPDATER_DISABLED false --type=constant",
        onlyif  => "${wpcli_bin} config get AUTOMATIC_UPDATER_DISABLED | grep -qv 'false'",
        cwd     => $wp_root,
        user    => $owner,
        require => Exec["${wp_servername} > Create wp-config.php"],
      }
    }
    'disabled': {
      exec { "${wp_servername} > set AUTOMATIC_UPDATER_DISABLED to true":
        command => "${wpcli_bin} config set AUTOMATIC_UPDATER_DISABLED true --type=constant",
        onlyif  => "${wpcli_bin} config get AUTOMATIC_UPDATER_DISABLED | grep -qv 'true'",
        cwd     => $wp_root,
        user    => $owner,
        require => Exec["${wp_servername} > Create wp-config.php"],
      }
    }
    default: {
      fail("unexpected value wpselfupdate parameter must be <disabled|enabled>, got '${wpselfupdate}'")
    }
  }
}
