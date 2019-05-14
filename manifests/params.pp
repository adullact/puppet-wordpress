#@summary Sets defaults values for some variables and parameters.
#
class wordpress::params {

  $default_wpcli_ensure = 'present'
  $_default_wpcli_version = '2.2.0'
  $_default_wpcli_baseurl = 'https://github.com/wp-cli/wp-cli/releases/download'
  $default_wpcli_url = "${_default_wpcli_baseurl}/v${_default_wpcli_version}/wp-cli-${_default_wpcli_version}.phar"
  $default_wpcli_bin = '/usr/local/bin/wp'

  $_os_family = $facts['os']['family']
  case $_os_family {
    'Debian': {
      $default_owner = 'www-data'
    }
    'RedHat': {
      # even with CentOS unsupported, this is not removed.
      # If a CentOS7 user installs expected php version this module should work.
      $default_owner = 'apache'
    }
    default: {
      fail ("unsupported OS ${_os_family}")
    }
  }
  $default_locale = 'en_US'
  $_rand = fqdn_rand(9999)
  $default_dbprefix = "wp${_rand}_"

  $default_hour_fact_update = 7

  $default_wpselfupdate = 'disabled'
  $default_wpresource_ensure = 'present'
  $default_wparchives_path = '/var/wordpress_archives'

  $default_install_secret_directory = '/etc/wordpress'

}
