#@summary download and manage resources aka plugins and themes.
#
#@param settings
#  Describes all availables settings in this module for all wordpress instances on this node. Defaults to empty hash.
#@param wpcli_bin
#  The PATH where the wpcli tools is deployed. Defaults to '/usr/local/bin/wp'.
#
#@api private
#
class wordpress::resource (
  Pattern['^/'] $wpcli_bin,
  Wordpress::Settings $settings = {},
) {
  assert_private()

  $settings.each | String $_wp_servername , Hash $_wp_configs | {

    # use some defaults if not provided
    $_owner = $_wp_configs['owner'] ? {
      String  => $_wp_configs['owner'],
      default => $wordpress::params::default_wpowner,
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
          default => $wordpress::params::default_wpresource_ensure,
        }

        $_wp_resource_name = $_wp_resource_settings['name']

        case $_wp_resource_ensure {
          'present': {
            wordpress::resource::install { "${_wp_servername} > ${_wp_resource_type} ${_wp_resource_name}":
              wp_servername    => $_wp_servername,
              wp_resource_type => $_wp_resource_type,
              wp_resource_name => $_wp_resource_name,
              wp_root          => $_wp_root,
              wpcli_bin        => $wpcli_bin,
              owner            => $_owner,
            }
            -> wordpress::resource::activate { "${_wp_servername} > ${_wp_resource_type} ${_wp_resource_name}":
              wp_servername    => $_wp_servername,
              wp_resource_type => $_wp_resource_type,
              wp_resource_name => $_wp_resource_name,
              wp_root          => $_wp_root,
              wpcli_bin        => $wpcli_bin,
              owner            => $_owner,
            }
          }
          'absent': {
            wordpress::resource::uninstall { "${_wp_servername} > ${_wp_resource_type} ${_wp_resource_name}":
              wp_servername    => $_wp_servername,
              wp_resource_type => $_wp_resource_type,
              wp_resource_name => $_wp_resource_name,
              wp_root          => $_wp_root,
              wpcli_bin        => $wpcli_bin,
              owner            => $_owner,
            }
          }
          'latest': {
            if $facts['wordpress'] and
              has_key($facts['wordpress'], $_wp_servername) and
              has_key($facts['wordpress']["${_wp_servername}"], $_wp_resource_type) and
              has_key($facts['wordpress']["${_wp_servername}"]["${_wp_resource_type}"], $_wp_resource_name) {
              $_wp_resource_update_status = $facts['wordpress']["${_wp_servername}"]["${_wp_resource_type}"]["${_wp_resource_name}"]['update']
              if $_wp_resource_update_status == 'available' {
                wordpress::resource::activate { "${_wp_servername} > ${_wp_resource_type} ${_wp_resource_name}":
                  wp_servername    => $_wp_servername,
                  wp_resource_type => $_wp_resource_type,
                  wp_resource_name => $_wp_resource_name,
                  wp_root          => $_wp_root,
                  wpcli_bin        => $wpcli_bin,
                  owner            => $_owner,
                }
                -> wordpress::resource::update { "${_wp_servername} > ${_wp_resource_type} ${_wp_resource_name}":
                  wp_servername    => $_wp_servername,
                  wp_resource_type => $_wp_resource_type,
                  wp_resource_name => $_wp_resource_name,
                  wp_root          => $_wp_root,
                  wpcli_bin        => $wpcli_bin,
                  owner            => $_owner,
                }
              } else {
                wordpress::resource::activate { "${_wp_servername} > ${_wp_resource_type} ${_wp_resource_name}":
                  wp_servername    => $_wp_servername,
                  wp_resource_type => $_wp_resource_type,
                  wp_resource_name => $_wp_resource_name,
                  wp_root          => $_wp_root,
                  wpcli_bin        => $wpcli_bin,
                  owner            => $_owner,
                }
              }
            } else {
              wordpress::resource::install { "${_wp_servername} > ${_wp_resource_type} ${_wp_resource_name}":
                wp_servername    => $_wp_servername,
                wp_resource_type => $_wp_resource_type,
                wp_resource_name => $_wp_resource_name,
                wp_root          => $_wp_root,
                wpcli_bin        => $wpcli_bin,
                owner            => $_owner,
              }
              -> wordpress::resource::activate { "${_wp_servername} > ${_wp_resource_type} ${_wp_resource_name}":
                wp_servername    => $_wp_servername,
                wp_resource_type => $_wp_resource_type,
                wp_resource_name => $_wp_resource_name,
                wp_root          => $_wp_root,
                wpcli_bin        => $wpcli_bin,
                owner            => $_owner,
              }
              -> wordpress::resource::update { "${_wp_servername} > ${_wp_resource_type} ${_wp_resource_name}":
                wp_servername    => $_wp_servername,
                wp_resource_type => $_wp_resource_type,
                wp_resource_name => $_wp_resource_name,
                wp_root          => $_wp_root,
                wpcli_bin        => $wpcli_bin,
                owner            => $_owner,
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
