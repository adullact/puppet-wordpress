#@summary deploy files to forge an external fact named 'wordpress'
#
#@param settings
#  Describes all availables settings in this module for all wordpress instances on this node. Defaults to empty hash.
#
class wordpress::external_fact (
  Wordpress::Settings $settings = {},
) {

  $_minute = fqdn_rand(59)

  #used by template('/wordpress/external_fact_wordpress.rb.erb')
  $_wproot = $settings.reduce( {} ) |$memo, $value| {
    if "${value[1]['ensure']}" != 'absent' {
      $mykey = $value[0]
      $mypath = "${value[1]['wproot']}"
      merge($memo,{ $mykey => $mypath })
    } else {
      $memo
    }
  }

  file {'/usr/local/sbin/external_fact_wordpress.rb':
    ensure  => 'file',
    content => template('wordpress/external_fact_wordpress.rb.erb'),
    owner   => 0,
    group   => 0,
    mode    => '0755',
    notify  => Exec['update external fact wordpress'],
  }
  ->
  cron { 'external_fact workpress update':
    command     => '/usr/local/sbin/external_fact_wordpress.rb > /opt/puppetlabs/facter/facts.d/wordpress.yaml &> /dev/null',
    environment => 'PATH=/usr/local/sbin:/usr/local/bin:/opt/puppetlabs/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    user        => 'root',
    hour        => '2',
    minute      => "${_minute}",
  }
}
