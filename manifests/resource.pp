#@summary download and manage resources aka plugins and themes.
#
#@param settings
#  Describes all availables settings in this module for all wordpress instances on this node. Defaults to empty hash.
#@param wpcli_bin
#  The PATH where the wpcli tools is deployed. Defaults to '/usr/local/bin/wp'.
#
class wordpress::resource (
  Pattern['^/'] $wpcli_bin,
  Wordpress::Settings $settings = {},
) {

  $settings.each | String $_wp_servername , Hash $_wp_configs | {

    # use some defaults if not provided
    $_owner = $_wp_configs['owner'] ? {
      String  => $_wp_configs['owner'],
      default => $::wordpress::params::default_wpowner,
    }
    $_wp_resources = $_wp_configs['wpresources'] ? {
      Hash => $_wp_configs['wpresources'],
      default => {},
    }
    $_wp_root = $_wp_configs['wproot']

    $_wp_resources.each | String $_wp_resource_type, Array $_wp_resource_list | {

      $_wp_resource_list.each | Hash $_wp_resource_settings | {

        $_wp_resource_ensure = $_wp_resource_settings['ensure'] ? {
          Enum['present','absent','latest'] => $_wp_resource_settings['ensure'],
          default => $::wordpress::params::default_wpresource_ensure,
        }

        $_wp_resource_name = $_wp_resource_settings['name']

        case $_wp_resource_ensure {
          'present': {
            exec { "${_wp_servername} > Install ${_wp_resource_type} ${_wp_resource_name}":
              command => "${wpcli_bin} --path=${_wp_root} ${_wp_resource_type} install ${_wp_resource_name}",
              unless  => "${wpcli_bin} --path=${_wp_root} ${_wp_resource_type} is-installed ${_wp_resource_name}",
              user    => $_owner,
              notify  => Exec['update external fact wordpress'],
            }
            ->
            exec { "${_wp_servername} > Activate ${_wp_resource_type} ${_wp_resource_name}":
              command => "${wpcli_bin} --path=${_wp_root} ${_wp_resource_type} activate ${_wp_resource_name}",
              onlyif  => [
                "${wpcli_bin} --path=${_wp_root} ${_wp_resource_type} is-installed ${_wp_resource_name}",
                "${wpcli_bin} --format=csv --path=${_wp_root} --fields=name,status ${_wp_resource_type} list | grep -qP '^${_wp_resource_name},inactive'",
                ] ,
              user    => $_owner,
              notify  => Exec['update external fact wordpress'],
            }

          }
          'absent': {
            exec { "${_wp_servername} > Uninstall ${_wp_resource_type} ${_wp_resource_name}":
              command => "${wpcli_bin} --path=${_wp_root} ${_wp_resource_type} uninstall ${_wp_resource_name}",
              onlyif  => "${wpcli_bin} --path=${_wp_root} ${_wp_resource_type} is-installed ${_wp_resource_name}",
              user    => $_owner,
              notify  => Exec['update external fact wordpress'],
            }
          }
          'latest': {
            $_wp_resource_update_status = $facts['wordpress']["${_wp_servername}"]["${_wp_resource_type}"]["${_wp_resource_name}"]['update']
            if $_wp_resource_update_status == 'available' {
              exec { "${_wp_servername} > Update ${_wp_resource_type} ${_wp_resource_name}":
                command => "${wpcli_bin} --path=${_wp_root} ${_wp_resource_type} update ${_wp_resource_name}",
                user    => $_owner,
                notify  => Exec['update external fact wordpress'],
              }
            }
          }
          default: {
            fail("unexpected value must be <present|absent|latest>, got '${_wp_resource_ensure}'")
          }
        } # end of case statement
      }
    }
  }
}
