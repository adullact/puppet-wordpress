
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


This module download the wpcli tool. And then use it to download and configure wordpress instances.

This module does not manage a multisite installation but it can create several wordpress installations.
And each installation can be managed separately.

## Setup

### What wordpress affects

As the name of module can explain, it affect wordpress installation and configuration.

This modules does not manage :
 * system account, owner of wordpress files.
 * nginx or apache vhost
 * mariadb or mysql database and user

They have to be created before for instance by `puppetlabs-mysql`, `puppetlabs-apache` and `puppetlabs-account`.

### Setup Requirements

This `wordpress` module depends on `puppetlabs-stdlib` and `puppet-archive`.

### Beginning with wordpress

The very basic steps needed for a user to get the module up and running. This can include setup steps, if necessary, or it can be an example of the most basic use of the module.

## Usage

Include three to five examples of the most important or common tasks a user can accomplish with your module. Show users how to accomplish more complex tasks that involve different types, classes, and functions working in tandem.

The follwoing code simple download and install `wpcli` :

```
class { 'wordpress' :
}
```

The following code :
  * download and install `wpcli`.
  * creates tables in a remote hosted database `wp_mywpname`.
  * install and configure core wordpress in the last available version.
  * set the title of the instance.
  * `wpcli` is ran as `wp` user. wordpress files are owned by already existing user `wp`. 

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
      wptitle       => 'the title is to deploy wordpress with puppet',
    }
  }
}
```

The following code :
  * download and install `wpcli`.
  * creates tables in a remote hosted database `wp_mywpname`.
  * install and configure core wordpress in the last available version.
  * set the title of the instance.
  * `wpcli` is ran as `wp` user. wordpress files are owned by already existing user `wp`. 
  * configure wordpress to update itself to last version available.

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
      wptitle       => 'the title is to deploy wordpress with puppet',
      wpselfupdate  => 'enabled',
    }
  }
}
```

The following code :
  * download and install `wpcli`.
  * creates tables in a remote hosted database `wp_mywpname`.
  * install and configure core wordpress in the last available version.
  * set the title of the instance.
  * `wpcli` is ran as `wp` user. wordpress files are owned by already existing user `wp`. 
  * configure puppet to make wordpress core and language update to last available version at about 3 AM.

If an update occured, you will find in `/var/wordpress_archives` :
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
      wptitle       => 'the title is to deploy wordpress with puppet',
    }
  }
}
```
The following code :
  * download and install `wpcli`.
  * creates tables in a remote hosted database `wp_mywpname`.
  * install and configure core wordpress in the last available version with french language.
  * set the title of the instance.
  * `wpcli` is ran as `wp` user. wordpress files are owned by already existing user `wp`. 
  * manage more than defaults themes and plugins provided with core.

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
      wptitle       => 'the title is to deploy wordpress with puppet',
      wpresources   => {
        plugin => [
          { name => 'plugin1', 'ensure' => 'present' },
          { name => 'plugin2', 'ensure' => 'absent' },
        ],
        theme => [
          { name => 'themenew', 'ensure' => 'present' },
          { name => 'themeold', 'ensure' => 'absent' },
        ]
      }
    }
  }
}
```


## Reference

Details in `REFERENCE.md`.

## Limitations

In the Limitations section, list any incompatibilities, known issues, or other warnings.

## Development

Home at URL https://gitlab.adullact.net/adullact/puppet-wordpress

Issues and MR are wellcome.

## Release Notes/Contributors/Etc.

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
