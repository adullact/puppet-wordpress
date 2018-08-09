# Changelog

All notable changes to this project will be documented in this file.

## Release 1.3.2

**Features**

**Bugfixes**

  * #36 Modifying settings of administrator modifies nothing.
  * #42 Modifying value of title in data modifies nothing.
  * #44 An already installed plugin but not yet activated is never activated.

**Known Issues**

## Release 1.3.1

**Features**

**Bugfixes**

  * #25 Command wp core config is deprecated.
  * #38 Update module compatiblility with pdk 1.6.1.
  * #41 Exec with tar commande to make archive files before upgrade need path.
  * #40 Add forgotten pdk new defined_type.

**Known Issues**

  * #36 Modifying settings of administrator modifies nothing.

## Release 1.3.0

**Features**

**Bugfixes**

  * #33 Be able to use parameter to define archives path.
  * #34 Use nokogiri provided by pdk for tests.
  * #35 Update README description.

**Known Issues**

## Release 1.2.0

**Features**

**Bugfixes**

  * #1  Fix resources attribute ensure set to latest from scratch.
  * #27 Fix typo in puppet strings.
  * #28 Fix WordPress core attribute ensure set to latest from scratch.
  * #29 Fix external fact variable extrapolation.
  * #30 Fix missing assume yes answer in `spec_helper_acceptance.rb`.
  * #31 Add note about private aspect in puppet string.
  * #32 Fix color in wp core check-update can mess up the data in the fact.

**Known Issues**

## Release 1.1.3

**Features**

**Bugfixes**

  * #20 Remove flag --allow-root when possible with WP-CLI.
  * #23 Add details about settings parameter.
  * #24 Modify default owner for CentOS.

**Known Issues**

  * #1 Fix resources attribute ensure set to latest from scratch.

## Release 1.1.2

**Features**

**Bugfixes**

  * #22 Add multi instances example in README.

**Known Issues**

  * #1 Fix resources attribute ensure set to latest from scratch.

## Release 1.1.1

**Features**

**Bugfixes**

  * #19 Fix README in usage with update by Puppet.
  * #21 Update metadata for release 1.1.1.

**Known Issues**

  * #1 Fix resources attribute ensure set to latest from scratch.

## Release 1.1.0

**Features**

**Bugfixes**

  * #5 Permit to modify hour of update for external_fact.
  * #15 Fix plugins are installed but not activated.
  * #16 Set `default_locale` to `en_US`.
  * #17 In README add subtitles for different examples of usage.

**Known Issues**

  * #1 Fix resources attribute ensure set to latest from scratch.

## Release 1.0.3

**Features**

**Bugfixes**

  * #9 Add acceptence tests about ressources.
  * #10 Add acceptence tests about management of several instances.
  * #13 Update README section Beginning with wordpress.

**Known Issues**

  * #1 Fix attribute ensure set to latest from scratch with resources management.
  * #5 Permit to modify hour of update for external_fact.
  * #15 Fix plugins are installed but not activated.
  * #16 Set `default_locale` to `en_US`.

## Release 1.0.2

**Features**

**Bugfixes**

  * #11 Remove lint setting `no-only_variable_string-check`.
  * #12 Write WP-CLI instead of wpcli in project description.

**Known Issues**

  * #1 Fix resources attribute ensure set to latest from scratch.
  * #5 Permit to modify hour of update for external_fact.

## Release 1.0.1

**Features**

**Bugfixes**

  * #7 Add missing keywords in metadata.json.
  * #8 Fix version in metadata.json.

**Known Issues**

  * #1 Fix resources attribute ensure set to latest from scratch.
  * #5 Permit to modify hour of update for external_fact.

## Release 1.0.0

**Features**

**Bugfixes**

  * #6 bump version to publish 1.0.0

**Known Issues**

  * #1 Fix resources attribute ensure set to latest from scratch.
  * #5 Permit to modify hour of update for external_fact.

## Release 0.2.0

**Features**

**Bugfixes**

  * #2 Fix license.
  * #3 Add informations in chapter `Limitations` in README.
  * #4 Update CHANGELOG.

**Known Issues**

  * #1 Fix resources attribute ensure set to latest from scratch.
  * #5 Permit to modify hour of update for external_fact.
