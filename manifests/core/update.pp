#@summary Backup and update WordPress core and language.
#
#@param wp_servername
#  The URI of the WordPress instance (like : www.foo.org).
#
#@param wp_root
#  The root path of the WordPress instance.
#
#@param owner
#  The OS account, owner of files of the WordPress instance.
#
#@param locale
#  Language used by WordPress instance (defaults en_US).
#
#@param wpselfupdate
#  Possible values : disabled , enabled (defaults disabled).
#
#@param wpcli_bin
#  The path of the WP-CLI tool.
#
#@param wparchives_path
#  Gives the path where are stored archives done before update managed by puppet (not by WordPress itself with `wpselfupdate`). Defaults to /var/wordpress_archives.
#
#@note This defined type should be considered as private.
define wordpress::core::update (
  String $wp_servername,
  String $wp_root,
  String $owner,
  String $locale,
  String $wpselfupdate,
  String $wpcli_bin,
  String $wparchives_path,
) {
  # four steps :
  # 1. make a backup
  # 2. update core wp
  # 3. update database
  # 4. update language

  $_date = strftime('%Y-%m-%d')

  # Export and Archive is done as root because directory $wparchives_path 
  # is with mode 0700 and owned by root.
  exec { "${wp_servername} > Export database before upgrade" :
    command => "${wpcli_bin} --allow-root --path=${wp_root} db export",
    cwd     => $wparchives_path,
    creates => "${wparchives_path}/${wp_servername}_${_date}.tar.gz",
  }
  ->
  exec { "${wp_servername} > Archive files before upgrade" :
    command => "tar -cvf ${wparchives_path}/${wp_servername}_${_date}.tar.gz .",
    cwd     => $wp_root,
    creates => "${wparchives_path}/${wp_servername}_${_date}.tar.gz",
  }

  case $locale {
    'en_US': {
      exec { "${wp_servername} > Update core wordpress" :
        command => "${wpcli_bin} --path=${wp_root} core update",
        user    => $owner,
        require => Exec["${wp_servername} > Archive files before upgrade"],
      }
    }
    default: {
      exec { "${wp_servername} > Update core wordpress" :
        command => "${wpcli_bin} --path=${wp_root} core update --locale=${locale}",
        user    => $owner,
        require => Exec["${wp_servername} > Archive files before upgrade"],
      }
    }
  }
  exec { "${wp_servername} > Update database structure" :
    command => "${wpcli_bin} --path=${wp_root} core update-db",
    user    => $owner,
    require => Exec["${wp_servername} > Update core wordpress"],
    notify  => Exec['update external fact wordpress'],
  }

  exec { "${wp_servername} > Update language" :
    command => "${wpcli_bin} --path=${wp_root} language core update",
    user    => $owner,
    require => Exec["${wp_servername} > Update core wordpress"],
    notify  => Exec['update external fact wordpress'],
  }
}
