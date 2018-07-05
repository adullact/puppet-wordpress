#@summary set defaults values for some variables and parameters.
#
class wordpress::params {

  $php_libs_4wordpress = []
  $apache_mods_4wordpress = ['php','rewrite',]

  $default_wpcli_ensure = 'present'
  $default_wpcli_url = 'https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar'
  $default_wpcli_bin = '/usr/local/bin/wp'

  $default_owner = 'www-data'
  $default_locale = 'fr_FR'
  $_rand = fqdn_rand(9999)
  $default_dbprefix = "wp${_rand}_"

  $default_wpselfupdate = 'disabled'
  $default_wpresource_ensure = 'present'
  $wordpress_archives = '/var/wordpress_archives'


}