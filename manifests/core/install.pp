#@summary Downloads and installs WordPress core and language.
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
#@note This defined type should be considered as private.
define wordpress::core::install (
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
  # download wordpress is path defined as wordpress root for the instance ${_wp_servername}

  case $locale {
    'en_US': {
      exec { "${wp_servername} > Download core":
        command => "${wpcli_bin} core download",
        cwd     => $wp_root,
        creates => "${wp_root}/wp-admin",
        user    => $owner,
      }
    }
    default: {
      exec { "${wp_servername} > Download core":
        command => "${wpcli_bin} core download --locale=${locale}",
        cwd     => $wp_root,
        creates => "${wp_root}/wp-admin",
        user    => $owner,
      }
    }
  }

  # creates the first wp-config.php of the new wordpress installation
  # and then ensure the content stay well configured for the instance ${wp_servername}

  exec { "${wp_servername} > Configure core":
    command => "${wpcli_bin} core config --dbhost=${db_host} --dbname=${db_name} --dbuser=${db_user} --dbpass=${db_passwd} --dbprefix=${dbprefix} --skip-check --force",
    cwd     => $wp_root,
    creates => "${wp_root}/wp-config.php",
    user    => $owner,
    notify  => Exec['update external fact wordpress'],
  }
  ->
  file_line {"${wp_servername} > set DB_NAME to ${db_name}":
    ensure => present,
    path   => "${wp_root}/wp-config.php",
    line   => "define( 'DB_NAME', '${db_name}' );",
    match  => '^define\( \'DB_NAME\',',
  }
  ->
  file_line {"${wp_servername} > set DB_USER to ${db_user}":
    ensure => present,
    path   => "${wp_root}/wp-config.php",
    line   => "define( 'DB_USER', '${db_user}' );",
    match  => '^define\( \'DB_USER\',',
  }
  ->
  file_line {"${wp_servername} > set DB_PASSWORD":
    ensure => present,
    path   => "${wp_root}/wp-config.php",
    line   => "define( 'DB_PASSWORD', '${db_passwd}' );",
    match  => '^define\( \'DB_PASSWORD\',',
  }
  ->
  file_line {"${wp_servername} > set DB_HOST to ${db_host}":
    ensure => present,
    path   => "${wp_root}/wp-config.php",
    line   => "define( 'DB_HOST', '${db_host}' );",
    match  => '^define\( \'DB_HOST\',',
  }
  ->
  # the database, granted user and credentials must be already created by other process
  # it creates all tables and data structure for the instannce ${wp_servername}
  exec { "${wp_servername} > Create core tables":
    command     => "${wpcli_bin} core install --url=${wp_servername} --title=\"${wp_title}\" --admin_user=${wp_admin} --admin_password=${wp_passwd} --admin_email=${wp_mail} --skip-email",
    cwd         => $wp_root,
    user        => $owner,
    subscribe   => [
      Exec["${wp_servername} > Configure core"],
      File_line["${wp_servername} > set DB_NAME to ${db_name}"],
      File_line["${wp_servername} > set DB_USER to ${db_user}"],
      File_line["${wp_servername} > set DB_PASSWORD"],
      File_line["${wp_servername} > set DB_HOST to ${db_host}"],
    ],
    refreshonly => true,
    notify      => Exec['update external fact wordpress'],
  }

  case $wpselfupdate {
    'enabled': {
      file_line { "${wp_servername} > set AUTOMATIC_UPDATER_DISABLED to false":
        ensure  => present,
        path    => "${wp_root}/wp-config.php",
        line    => "define( 'AUTOMATIC_UPDATER_DISABLED', 'false' );",
        match   => '^define\( \'AUTOMATIC_UPDATER_DISABLED\',',
        require => Exec["${wp_servername} > Configure core"],
      }
    }
    'disabled': {
      file_line { "${wp_servername} > set AUTOMATIC_UPDATER_DISABLED to true":
        ensure  => present,
        path    => "${wp_root}/wp-config.php",
        line    => "define( 'AUTOMATIC_UPDATER_DISABLED', 'true' );",
        match   => '^define\( \'AUTOMATIC_UPDATER_DISABLED\',',
        require => Exec["${wp_servername} > Configure core"],
      }
    }
    default: {
      fail("unexpected value wpselfupdate parameter must be <disabled|enabled>, got '${wpselfupdate}'")
    }
  }
}
