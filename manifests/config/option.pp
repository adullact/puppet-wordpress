#
# @summary Configure an option in the desired state
#
define wordpress::config::option(
  String $wp_servername,
  String $wp_root,
  String $owner,
  String $wp_option_name,
  String $wp_option_value,
  String $wpcli_bin,
) {

  exec { "${wp_servername} > update ${wp_option_name}" :
    command => "${wpcli_bin} option update ${wp_option_name} '${wp_option_value}'",
    cwd     => $wp_root,
    user    => $owner,
    unless  => "${wpcli_bin} option get ${wp_option_name} | /bin/grep -q '^${wp_option_value}'",
  }

}
