#@summary Use WP-CLI to download last version of WordPress core, create tables in database and configure WordPress. 
#
#@param wpcli_bin 
#  The PATH where the WP-CLI tools is deployed.
#@param settings
#  Describes all availables settings in this module for all wordpress instances on this node. Defaults to empty hash.
#
#@api private
#
class wordpress::site (
  Pattern['^/'] $wpcli_bin,
  Wordpress::Settings $settings = {},
  Pattern['^/'] $install_secret_directory = $wordpress::params::default_install_secret_directory,
) {
  assert_private()
  file { $install_secret_directory :
    ensure => directory,
    owner  => 0,
    group  => 0,
    mode   => '0700',
  }

  $settings.each | String $_wp_servername , Hash $_wp_configs | {

    # use some defaults if not provided
    $_ensure = $_wp_configs['ensure'] ? {
      Enum['present','absent','latest'] => $_wp_configs['ensure'],
      default => 'present',
    }
    $_owner = $_wp_configs['owner'] ? {
      String  => $_wp_configs['owner'],
      default => $wordpress::params::default_wpowner,
    }

    if $_ensure == 'present' or $_ensure == 'latest' {
      wordpress::config::option { "${_wp_servername} > change title" :
        wp_servername   => $_wp_servername,
        wp_root         => $_wp_configs['wproot'],
        owner           => $_owner,
        wp_option_name  => 'blogname',
        wp_option_value => $_wp_configs['wptitle'],
        wpcli_bin       => $wpcli_bin,
      }

      wordpress::config::admin { "${_wp_servername} > change administrator settings" :
        wp_servername   => $_wp_servername,
        wp_root         => $_wp_configs['wproot'],
        owner           => $_owner,
        wp_admin_login  => $_wp_configs['wpadminuser'],
        wp_admin_passwd => $_wp_configs['wpadminpasswd'],
        wp_admin_email  => $_wp_configs['wpadminemail'],
        wpcli_bin       => $wpcli_bin,
      }

    }
  }
}

