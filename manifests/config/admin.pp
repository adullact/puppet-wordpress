# @summary Configure settings (name password and email) of one user in the desired state.
#
#@param wp_servername
#  The URI of the WordPress instance (like : www.foo.org).
#@param wp_root
#  The root path of the WordPress instance.
#@param owner
#  The OS account, owner of files of the WordPress instance.
#@param wp_user_login
#  The login of the user to be configured (if the login does not exist, a new user is created).
#@param wp_user_passwd
#  The desired value of the user's password to be configured.
#@param wp_user_email
#  The desired value of the user's email to be configured.
#@param wpcli_bin
#  The path of the WP-CLI tool.
#@note This defined type should be considered as private.
#
define wordpress::config::admin(
  String $wp_servername,
  String $wp_root,
  String $owner,
  String $wp_admin_login,
  String $wp_admin_passwd,
  String $wp_admin_email,
  String $wpcli_bin,
  String $wp_admin_passwd_hash = wordpress::password_hash($wp_admin_passwd),
) {

  $_secret_directory = $wordpress::site::install_secret_directory

  exec { "${wp_servername} > create ${wp_admin_login} login" :
    command => "${wpcli_bin} user create ${wp_admin_login} ${wp_admin_email} --user_pass='${wp_admin_passwd}' --role=administrator",
    cwd     => $wp_root,
    user    => $owner,
    unless  => "${wpcli_bin} user get ${wp_admin_login}",
  }

  exec { "${wp_servername} > set ${wp_admin_login} email" :
    command => "${wpcli_bin} user update ${wp_admin_login} --user_email='${wp_admin_email}'",
    cwd     => $wp_root,
    user    => $owner,
    unless  => "${wpcli_bin} user get ${wp_admin_login} --format=csv --field=user_email | /bin/grep -q '^${wp_admin_email}$'",
  }

  # this file type use $wp_admin_passwd_hash variable.
  file { "${_secret_directory}/${wp_servername}.conf":
    ensure  => file,
    owner   => 0,
    group   => 0,
    mode    => '0600',
    content => template('wordpress/secret_file.erb'),
  }

  exec { "${wp_servername} > set ${wp_admin_login} password":
    command     => "${wpcli_bin} user update ${wp_admin_login} --user_pass='${wp_admin_passwd}'",
    cwd         => $wp_root,
    user        => $owner,
    subscribe   => File["${_secret_directory}/${wp_servername}.conf"],
    refreshonly => true,
  }

}
