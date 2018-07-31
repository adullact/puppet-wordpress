#@summary Deploy files to forge an external fact named 'wordpress'
#
#@param settings
#  Describes all availables settings in this module for all WordPress instances on this node. Defaults to empty hash.
#
#@param hour_fact_update
#  Gives the approximate hour (between 1 and 23) when external fact is update (some random is added).
#
#@note This class should be considered as private.
class wordpress::external_fact (
  Integer[1,23] $hour_fact_update,
  Wordpress::Settings $settings = {},
) {

  $_minute = fqdn_rand(59)
  $_fact_script_path = '/usr/local/sbin/external_fact_wordpress.rb'
  $_fact_output_yaml = '/opt/puppetlabs/facter/facts.d/wordpress.yaml'

  #used by template('/wordpress/external_fact_wordpress.rb.erb')
  $_wproot = $settings.reduce( {} ) |$memo, $value| {
    if $value[1]['ensure'] != 'absent' {
      $mykey = $value[0]
      $mypath = $value[1]['wproot']
      merge($memo,{ $mykey => $mypath })
    } else {
      $memo
    }
  }

  file { $_fact_script_path :
    ensure  => 'file',
    content => template('wordpress/external_fact_wordpress.rb.erb'),
    owner   => 0,
    group   => 0,
    mode    => '0755',
    notify  => Exec['update external fact wordpress'],
  }
  ->
  exec { 'update external fact wordpress':
    command     => "${_fact_script_path} > ${_fact_output_yaml}",
    user        => 'root',
    refreshonly => true,
  }

  cron { 'external_fact workpress update':
    command     => "${_fact_script_path} > ${_fact_output_yaml} &> /dev/null",
    environment => 'PATH=/usr/local/sbin:/usr/local/bin:/opt/puppetlabs/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    user        => 'root',
    hour        => $hour_fact_update,
    minute      => $_minute,
  }

}
