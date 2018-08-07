#@summary Use WP-CLI to download last version of WordPress core, create tables in database and configure WordPress. 
#
#@param wpcli_bin 
#  The PATH where the WP-CLI tools is deployed.
#
#@param wparchives_path
#  Gives the path where are stored archives done before update managed by puppet (not by WordPress itself with `wpselfupdate`). Defaults to /var/wordpress_archives.
#
#@param settings
#  Describes all availables settings in this module for all wordpress instances on this node. Defaults to empty hash.
#
#@note This class should be considered as private.
class wordpress::site (
  Pattern['^/'] $wpcli_bin,
  Wordpress::Settings $settings = {},
) {

  $settings.each | String $_wp_servername , Hash $_wp_configs | {

    # use some defaults if not provided
    $_ensure = $_wp_configs['ensure'] ? {
      Enum['present','absent','latest'] => $_wp_configs['ensure'],
      default => 'present',
    }
    $_owner = $_wp_configs['owner'] ? {
      String  => $_wp_configs['owner'],
      default => $::wordpress::params::default_wpowner,
    }

    if $_ensure == 'present' or $_ensure == 'latest' {
      wordpress::config::option { "${_wp_servername} > set title" :
        wp_servername   => $_wp_servername,
        wp_root         => $_wp_configs['wproot'],
        owner           => $_owner,
        wp_option_name  => 'blogname',
        wp_option_value => $_wp_configs['wptitle'],
        wpcli_bin       => $wpcli_bin,
      }
    }
  }
}

