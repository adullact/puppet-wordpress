
# wordpress

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with wordpress](#setup)
    * [What wordpress affects](#what-wordpress-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with wordpress](#beginning-with-wordpress)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)
5. [Development - Guide for contributing to the module](#development)

## Description

This module downloads the WP-CLI tool and then uses it to download and configure a WordPress instances.

This module does not manage a multisite installation but it can create several WordPress installations.
And each installation can be managed separately.

## Setup

### What wordpress affects

As the name of module can explain, it affects WordPress installation and configuration.

This modules does not manage :
 * system account, owner of WordPress files.
 * nginx or apache vhost
 * mariadb or mysql database and user
 * php install

They have to be created before for instance by `puppetlabs-mysql`, `puppetlabs-apache` and `puppetlabs-account`.

### Setup Requirements

This `wordpress` module use `cron` service and depends on `puppetlabs-stdlib` and `puppet-archive`

### Beginning with wordpress

The very basic step :

```
class { 'wordpress' :
}
```

## Usage

### Typical installation

The following code :
  * downloads and installs WP-CLI.
  * downloads and installs core WordPress in the last available version.
  * creates tables in an already existing database `wp_mywpname`.
  * configures core WordPress
  * sets the title of the instance.
  * WP-CLI is ran as `wp` user. Files are owned by already existing user `wp`. 

```
class { 'wordpress' :
  settings => {
    'mywpname.mydomaine.com' => {
      wproot        => '/var/www/mywpname',
      owner         => 'wp',
      dbhost        => 'YY.YY.YY.YY',
      dbname        => 'wp_mywpname',
      dbuser        => 'mywp_dbusername',
      dbpasswd      => 'secretpass',
      wpadminuser   => 'mywp_adminuser',
      wpadminpasswd => 'othersecret',
      wpadminemail  => 'foo@mydomain.com',
      wptitle       => 'the title is to deploy WordPress with puppet',
    }
  }
}
```

### Typical installation + self update by WordPress

The following code :
  * downloads and installs WP-CLI.
  * downloads and installs core WordPress in the last available version.
  * creates tables in an already existing database `wp_mywpname`.
  * configures core WordPress
  * sets the title of the instance.
  * WP-CLI is ran as `wp` user. Files are owned by already existing user `wp`. 
  * enables WordPress internal self update process (disabled by default).

```
class { 'wordpress' :
  settings => {
    'mywpname.mydomaine.com' => {
      wproot        => '/var/www/mywpname',
      owner         => 'wp',
      dbhost        => 'YY.YY.YY.YY',
      dbname        => 'wp_mywpname',
      dbuser        => 'mywp_dbusername',
      dbpasswd      => 'secretpass',
      wpadminuser   => 'mywp_adminuser',
      wpadminpasswd => 'othersecret',
      wpadminemail  => 'foo@mydomain.com',
      wptitle       => 'the title is to deploy WordPress with puppet',
      wpselfupdate  => 'enabled',
    }
  }
}
```

### Typical installation + update by Puppet

The following code :
  * downloads and installs WP-CLI.
  * downloads and installs core WordPress in the last available version.
  * creates tables in an already existing database `wp_mywpname`.
  * configures core WordPress
  * sets the title of the instance.
  * WP-CLI is ran as `wp` user. Files are owned by already existing user `wp`. 
  * disables WordPress internal self update process.
  * configures puppet to make WordPress core and language update to latest available version.

If an update occured (checked one time each day), you will 
find in `/var/wordpress_archives` :
 * dump of database that was there before the update.
 * archive of files that were there before the update.

```
class { 'wordpress' :
  settings => {
    'mywpname.mydomaine.com' => {
      ensure        => 'latest',
      wproot        => '/var/www/mywpname',
      owner         => 'wp',
      dbhost        => 'YY.YY.YY.YY',
      dbname        => 'wp_mywpname',
      dbuser        => 'mywp_dbusername',
      dbpasswd      => 'secretpass',
      wpadminuser   => 'mywp_adminuser',
      wpadminpasswd => 'othersecret',
      wpadminemail  => 'foo@mydomain.com',
      wptitle       => 'the title is to deploy WordPress with puppet',
    }
  }
}
```

### Typical installation + add themes + add plugins + locale

The following code :
  * downloads and installs WP-CLI.
  * downloads and installs core WordPress in the last available version and in french.
  * creates tables in an already existing database `wp_mywpname`.
  * configures core WordPress
  * sets the title of the instance.
  * WP-CLI is ran as `wp` user. Files are owned by already existing user `wp`. 
  * manages more than defaults themes and plugins provided with core.

```
class { 'wordpress' :
  settings => {
    'mywpname.mydomaine.com' => {
      wproot        => '/var/www/mywpname',
      owner         => 'wp',
      locale        => 'fr_FR',
      dbhost        => 'YY.YY.YY.YY',
      dbname        => 'wp_mywpname',
      dbuser        => 'mywp_dbusername',
      dbpasswd      => 'secretpass',
      wpadminuser   => 'mywp_adminuser',
      wpadminpasswd => 'othersecret',
      wpadminemail  => 'foo@mydomain.com',
      wptitle       => 'the title is to deploy WordPress with puppet',
      wpresources   => {
        plugin => [
          { name => 'plugin1', 'ensure' => 'present' },
          { name => 'plugin2', 'ensure' => 'absent' },
        ],
        theme => [
          { name => 'themenew', 'ensure' => 'latest' },
          { name => 'themeold', 'ensure' => 'absent' },
        ]
      },
    },
  },
}
```

### Several installations

The following code makes two installations on same Puppet node with dedicated settings :
  * only WordPress in `wp2.foo.org` in updated by Puppet, the other is not updated at all.
  * the two WordPress instances use the same database server.
  * the list of used plugins and themes configure are differents in each intance.

```
class { 'wordpress': 
  settings => {
    'wp2.foo.org' => {
      ensure        => 'latest',
      owner         => 'wp2',
      locale        => 'fr_FR',
      dbhost        => 'XX.XX.XX.XX',
      dbname        => 'wordpress2',
      dbuser        => 'wp2userdb',
      dbpasswd      => 'secret_a',
      wproot        => '/var/www/wp2.foo.org',
      wptitle       => 'hola this wp2 instance is installed by puppet',
      wpadminuser   => 'wpadmin',
      wpadminpasswd => 'secret_b',
      wpadminemail  => 'bar@foo.org',
      wpresources   => {
        plugin => [
          { name => 'plugin_a', 'ensure' => 'latest' },
          { name => 'plugin_b', 'ensure' => 'absent' },
        ],
        theme => [
          { name => 'themenew_a', },
          { name => 'themeold_a', 'ensure' => 'absent' },
        ]
      },
    },
    'wp3.foo.org' => {
      owner         => 'wp3',
      dbhost        => 'XX.XX.XX.XX',
      dbname        => 'wordpress3',
      dbuser        => 'wp3userdb',
      dbpasswd      => 'secret_c',
      wproot        => '/var/www/wp3.foo.org',
      wptitle       => 'hola this wp3 instance is installed by puppet',
      wpadminuser   => 'wpadmin',
      wpadminpasswd => 'secret_d',
      wpadminemail  => 'bar@foo.org',
      wpresources   => {
        plugin => [
          { name => 'plugin_a', },
          { name => 'plugin_b', },
          { name => 'plugin_c', },
          { name => 'plugin_d', 'ensure' => 'absent' },
        ],
        theme => [
          { name => 'themenew_b', },
          { name => 'themeold_a', 'ensure' => 'absent' },
        ]
      },
    },
  },
}
```

## Reference

Details in `REFERENCE.md`.

## Limitations

This module is tested with following OSes :
  * Ubuntu 16.04
  * Debian 8
  * CentOS 7

Known bugs are listed in `CHANGELOG.md` file.

## Development

Home at URL https://gitlab.adullact.net/adullact/puppet-wordpress

Issues and MR are welcome.

Mirrored at URL https://github.com/adullact/puppet-wordpress

## Release Notes/Contributors/License.

Details in `CHANGELOG.md`.

```
Copyright (C) 2018 Association des Développeurs et Utilisateurs de Logiciels Libres
                     pour les Administrations et Colléctivités Territoriales.

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/agpl.html>.

```
