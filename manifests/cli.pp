#@summary
#  Install wpcli tool.
#
#@param wpcli_url
#  http URL where to download the wpcli tool.
#@param wpcli_bin
#  The PATH where the wpcli tools is deployed.
#@param ensure
#  The desirated state about wpcli tools. Valid values are 'present', 'absent'. Defaults to 'present'.
#
class wordpress::cli (
  Pattern['^http'] $wpcli_url,
  Pattern['^/'] $wpcli_bin,
  Enum['present','absent'] $ensure = $wordpress::params::default_wpcli_ensure,
) {

  case $ensure {
    'present': {

      archive { 'wpcli_bin' :
        ensure => present,
        path   => "${wpcli_bin}",
        source => "${wpcli_url}",
        user   => 0,
        group  => 0,
      }
      ->
      file { "${wpcli_bin}" :
        ensure => file,
        owner  => 0,
        group  => 0,
        mode   => '0755',
      }

    }
    'absent': {
      file {"${wpcli_bin}":
        ensure => absent,
      }
    }
    default: {
      fail('unexpected value for ensure parameter')
    }
  }

}
