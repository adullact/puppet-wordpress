#@summary Activates an already installed resource aka plugin or theme.
#
#@param wp_servername
#  The URI of the WordPress instance (like : www.foo.org).
#@param wp_resource_type
#  The type of resource aka plugin or theme.
#@param wp_resource_name
#  The name of the resource. You can find the name in column `slug` in output of `wp plugin search <search>`.
#@param wp_root
#  The root path of the WordPress instance.
#@param wpcli_bin
#  The path of the WP-CLI tool.
#@param owner
#  The OS account, owner of files of the WordPress instance.
#
define wordpress::resource::activate (
  String $wp_servername,
  String $wp_resource_type,
  String $wp_resource_name,
  String $wp_root,
  String $wpcli_bin,
  String $owner,
) {
  exec { "${wp_servername} > activate ${wp_resource_type} ${wp_resource_name}":
    command => "${wpcli_bin} --path=${wp_root} ${wp_resource_type} activate ${wp_resource_name}",
    onlyif  => [
      "${wpcli_bin} --path=${wp_root} ${wp_resource_type} is-installed ${wp_resource_name}",
      "${wpcli_bin} --format=csv --path=${wp_root} --fields=name,status ${wp_resource_type} list | grep -qP '^${wp_resource_name},inactive'",
      ] ,
    user    => $owner,
    notify  => Exec['update external fact wordpress'],
  }
}
