require 'spec_helper_acceptance'

wpcli_bin = '/usr/local/bin/wp'
wp_root = '/var/www/wordpress.foo.org'
wp2_root = '/var/www/wp2.foo.org'
wp3_root = '/var/www/wp3.foo.org'
wparchives = '/var/mywp_archives'
crontabs_path = if fact('osfamily') == 'Debian'
                  '/var/spool/cron/crontabs'
                elsif fact('osfamily') == 'RedHat'
                  '/var/spool/cron/'
                else
                  '/unsupported_OS'
                end

describe 'wordpress class' do
  context 'with defaults parameters' do
    it 'applies idempotently' do
      pp = "class { 'wordpress': }"
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe file(wpcli_bin.to_s) do
      it { is_expected.to be_file }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'root' }
      it { is_expected.to be_mode 755 }
    end
  end

  context 'with parameters about one wordpress with defaults plugins and themes' do
    it 'applies idempotently' do
      pp = <<-EOS
      class { 'wordpress':
        settings => {
          'wordpress.foo.org' => {
            owner         => 'wp',
            dbhost        => '127.0.0.1',
            dbname        => 'wordpress',
            dbuser        => 'wpuserdb',
            dbpasswd      => 'kiki',
            wproot        => '/var/www/wordpress.foo.org',
            wptitle       => 'hola this wordpress instance is installed by puppet',
            wpadminuser   => 'wpadmin',
            wpadminpasswd => 'secret',
            wpadminemail  => 'bar@foo.org',
          }
        }
      }
      EOS
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe file("#{crontabs_path}/root") do
      it { is_expected.to contain('7 * * * /usr/local/sbin/external_fact_wordpress.rb > /opt/puppetlabs/facter/facts.d/wordpress.yaml') }
    end

    describe file(wpcli_bin.to_s) do
      it { is_expected.to be_file }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'root' }
      it { is_expected.to be_mode 755 }
    end

    describe file(wp_root.to_s) do
      it { is_expected.to be_directory }
      it { is_expected.to be_owned_by 'wp' }
      it { is_expected.to be_grouped_into 'wp' }
      it { is_expected.to be_mode 750 }
    end

    describe file("#{wp_root}/wp-config.php") do
      it { is_expected.to be_file }
      it { is_expected.to be_owned_by 'wp' }
      it { is_expected.to be_grouped_into 'wp' }
      it { is_expected.to be_mode 644 }
    end

    describe command('curl -L http://wordpress.foo.org') do
      its(:stdout) { is_expected.to match %r{.*hola this wordpress instance is installed by puppet.*} }
    end

    describe command('curl -c /tmp/wp-step1.tmp -d "log=wpadmin" -d "pwd=secret" http://wordpress.foo.org/wp-login.php') do
      its(:exit_status) { is_expected.to eq 0 }
    end

    describe command('curl -b /tmp/wp-step1.tmp http://wordpress.foo.org/wp-admin/') do
      its(:stdout) { is_expected.to match %r{.*adminmenu.*} }
    end

    describe command("wp --allow-root --format=csv --path=#{wp_root} --fields=language,status --status=active language core list") do
      its(:stdout) { is_expected.to match %r{.*en_US,active.*} }
    end
  end

  context 'with parameters about one wordpress instance with custon hour of external fact update' do
    it 'applies idempotently' do
      pp = <<-EOS
      class { 'wordpress':
        hour_fact_update => 3,
        settings => {
          'wordpress.foo.org' => {
            owner         => 'wp',
            dbhost        => '127.0.0.1',
            dbname        => 'wordpress',
            dbuser        => 'wpuserdb',
            dbpasswd      => 'kiki',
            wproot        => '/var/www/wordpress.foo.org',
            wptitle       => 'hola this wordpress instance is installed by puppet',
            wpadminuser   => 'wpadmin',
            wpadminpasswd => 'secret',
            wpadminemail  => 'bar@foo.org',
          },
        }
      }
      EOS
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe file("#{crontabs_path}/root") do
      it { is_expected.to contain('3 * * * /usr/local/sbin/external_fact_wordpress.rb > /opt/puppetlabs/facter/facts.d/wordpress.yaml') }
    end
  end

  context 'with parameters setting new password for admin user and new title for site ' do
    it 'applies idempotently' do
      pp = <<-EOS
      class { 'wordpress':
        settings => {
          'wordpress.foo.org' => {
            owner         => 'wp',
            dbhost        => '127.0.0.1',
            dbname        => 'wordpress',
            dbuser        => 'wpuserdb',
            dbpasswd      => 'kiki',
            wproot        => '/var/www/wordpress.foo.org',
            wptitle       => 'hola this is modified',
            wpadminuser   => 'wpadmin',
            wpadminpasswd => 'newsecret',
            wpadminemail  => 'bar@foo.org',
          }
        }
      }
      EOS
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe command('curl -L http://wordpress.foo.org') do
      its(:stdout) { is_expected.to match %r{.*hola this is modified.*} }
    end

    describe command('curl -c /tmp/wp-step2.tmp -d "log=wpadmin" -d "pwd=newsecret" http://wordpress.foo.org/wp-login.php') do
      its(:exit_status) { is_expected.to eq 0 }
    end

    describe command('curl -b /tmp/wp-step2.tmp http://wordpress.foo.org/wp-admin/') do
      its(:stdout) { is_expected.to match %r{.*adminmenu.*} }
    end
  end

  context 'with parameters about one wordpress with customs plugins and themes' do
    it 'applies idempotently' do
      pp = <<-EOS
      class { 'wordpress':
        settings => {
          'wordpress.foo.org' => {
            owner         => 'wp',
            dbhost        => '127.0.0.1',
            dbname        => 'wordpress',
            dbuser        => 'wpuserdb',
            dbpasswd      => 'kiki',
            wproot        => '/var/www/wordpress.foo.org',
            wptitle       => 'hola this wordpress instance is installed by puppet',
            wpadminuser   => 'wpadmin',
            wpadminpasswd => 'secret',
            wpadminemail  => 'bar@foo.org',
            wpresources   => {
              plugin => [
                {name => 'akismet', ensure => 'latest'},
                {name => 'wp-piwik', ensure => 'present'},
                {name => 'hello', ensure => 'absent'},
              ],
              theme  => [
                {name => 'twentyseventeen', ensure => 'present'},
                {name => 'twentysixteen', ensure => 'absent'},
              ],
            }
          }
        }
      }
      EOS
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe file(wpcli_bin.to_s) do
      it { is_expected.to be_file }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'root' }
      it { is_expected.to be_mode 755 }
    end

    describe file(wp_root.to_s) do
      it { is_expected.to be_directory }
      it { is_expected.to be_owned_by 'wp' }
      it { is_expected.to be_grouped_into 'wp' }
      it { is_expected.to be_mode 750 }
    end

    describe file("#{wp_root}/wp-config.php") do
      it { is_expected.to be_file }
      it { is_expected.to be_owned_by 'wp' }
      it { is_expected.to be_grouped_into 'wp' }
      it { is_expected.to be_mode 644 }
    end

    describe command('curl -L http://localhost') do
      its(:stdout) { is_expected.to match %r{.*hola this wordpress instance is installed by puppet.*} }
    end

    describe command("/usr/local/bin/wp --allow-root --format=csv --path=#{wp_root} --fields=name,status plugin list") do
      its(:stdout) { is_expected.to match %r{.*akismet,active.*} }
    end

    describe command("/usr/local/bin/wp --allow-root --format=csv --path=#{wp_root} --fields=name,status plugin list") do
      its(:stdout) { is_expected.to match %r{.*wp-piwik,active.*} }
    end

    describe command("/usr/local/bin/wp --allow-root --format=csv --path=#{wp_root} --fields=name,status plugin list") do
      its(:stdout) { is_expected.not_to match %r{.*hello,.*} }
    end

    describe command("/usr/local/bin/wp --allow-root --format=csv --path=#{wp_root} --fields=name,status theme list") do
      its(:stdout) { is_expected.to match %r{.*twentyseventeen,active.*} }
    end

    describe command("/usr/local/bin/wp --allow-root --format=csv --path=#{wp_root} --fields=name,status theme list") do
      its(:stdout) { is_expected.not_to match %r{.*twentysixteen,active.*} }
    end

    describe file("#{crontabs_path}/root") do
      it { is_expected.to contain('7 * * * /usr/local/sbin/external_fact_wordpress.rb > /opt/puppetlabs/facter/facts.d/wordpress.yaml') }
    end
  end

  context 'with parameters about two wordpress instances with customs locales and archives path' do
    it 'applies idempotently' do
      pp = <<-EOS
      class { 'wordpress':
        wparchives_path => '/var/mywp_archives',
        settings        => {
          'wp2.foo.org' => {
            ensure        => 'latest',
            owner         => 'wp2',
            locale        => 'fr_FR',
            dbhost        => '127.0.0.1',
            dbname        => 'wordpress2',
            dbuser        => 'wp2userdb',
            dbpasswd      => 'kiki',
            wproot        => '/var/www/wp2.foo.org',
            wptitle       => 'hola this wp2 instance is installed by puppet',
            wpadminuser   => 'wpadmin',
            wpadminpasswd => 'lolo',
            wpadminemail  => 'bar@foo.org',
            wpresources   => {
              plugin => [
                {name => 'akismet', ensure => 'latest'},
                {name => 'wp-piwik', ensure => 'present'},
                {name => 'hello', ensure => 'absent'},
              ],
            },
          },
          'wp3.foo.org' => {
            owner         => 'wp3',
            dbhost        => '127.0.0.1',
            dbname        => 'wordpress3',
            dbuser        => 'wp3userdb',
            dbpasswd      => 'kiki',
            wproot        => '/var/www/wp3.foo.org',
            wptitle       => 'hola this wp3 instance is installed by puppet',
            wpadminuser   => 'wpadmin',
            wpadminpasswd => 'lolo',
            wpadminemail  => 'bar@foo.org',
          }
        }
      }
      EOS
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end

    describe file(wpcli_bin.to_s) do
      it { is_expected.to be_file }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'root' }
      it { is_expected.to be_mode 755 }
    end

    describe file(wp2_root.to_s) do
      it { is_expected.to be_directory }
      it { is_expected.to be_owned_by 'wp2' }
      it { is_expected.to be_grouped_into 'wp2' }
      it { is_expected.to be_mode 750 }
    end

    describe file("#{wp2_root}/wp-config.php") do
      it { is_expected.to be_file }
      it { is_expected.to be_owned_by 'wp2' }
      it { is_expected.to be_grouped_into 'wp2' }
      it { is_expected.to be_mode 644 }
    end

    describe command("wp --allow-root --format=csv --path=#{wp2_root} --fields=language,status --status=active language core list") do
      its(:stdout) { is_expected.to match %r{.*fr_FR,active.*} }
    end
    describe command("/usr/local/bin/wp --allow-root --format=csv --path=#{wp2_root} --fields=name,status plugin list") do
      its(:stdout) { is_expected.to match %r{.*akismet,active.*} }
    end
    describe command("/usr/local/bin/wp --allow-root --format=csv --path=#{wp2_root} --fields=name,status plugin list") do
      its(:stdout) { is_expected.to match %r{.*wp-piwik,active.*} }
    end
    describe command("/usr/local/bin/wp --allow-root --format=csv --path=#{wp2_root} --fields=name,status plugin list") do
      its(:stdout) { is_expected.not_to match %r{.*hello,.*} }
    end

    describe file(wparchives.to_s) do
      it { is_expected.to be_directory }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'root' }
      it { is_expected.to be_mode 700 }
    end
    describe command("ls #{wparchives}") do
      its(:stdout) { is_expected.to match %r{.*wordpress2.*sql.*} }
    end
    describe command("ls #{wparchives}") do
      its(:stdout) { is_expected.to match %r{.*wp2\.foo\.org.*\.tar\.gz.*} }
    end

    describe file(wp3_root.to_s) do
      it { is_expected.to be_directory }
      it { is_expected.to be_owned_by 'wp3' }
      it { is_expected.to be_grouped_into 'wp3' }
      it { is_expected.to be_mode 750 }
    end

    describe file("#{wp3_root}/wp-config.php") do
      it { is_expected.to be_file }
      it { is_expected.to be_owned_by 'wp3' }
      it { is_expected.to be_grouped_into 'wp3' }
      it { is_expected.to be_mode 644 }
    end

    describe command("wp --allow-root --format=csv --path=#{wp3_root} --fields=language,status --status=active language core list") do
      its(:stdout) { is_expected.to match %r{.*en_US,active.*} }
    end
  end

  context 'with a buggy parameter' do
    it 'is expected to get error message' do
      pp = <<-EOS
      class { 'wordpress':
        settings => {
          'wordpress.foo.org' => {
            buggy         => 'wp',
            dbhost        => '127.0.0.1',
            dbname        => 'wordpress',
            dbuser        => 'wpuserdb',
            dbpasswd      => 'kiki',
            wproot        => '/var/www/wordpress.foo.org',
            wptitle       => 'hola this wordpress instance is installed by puppet',
            wpadminuser   => 'wpadmin',
            wpadminpasswd => 'lolo',
            wpadminemail  => 'bar@foo.org',
          }
        }
      }
      EOS
      apply_manifest(pp, expect_failures: true)
    end
  end
end
