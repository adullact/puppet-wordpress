require 'spec_helper_acceptance'

$wpcli_bin = '/usr/local/bin/wp'
$wp_root = '/var/www/wordpress.foo.org'
$wp2_root = '/var/www/wp2.foo.org'
$wp3_root = '/var/www/wp3.foo.org'

describe 'wordpress class' do

  context 'with defaults parameters' do
    it 'applies idempotently' do
      pp = "class { 'wordpress': }"
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes  => true)
    end
  
    describe file($wpcli_bin) do
      it { should be_file }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
      it { should be_mode 755 }
    end
  end

  context 'with parameters about one wordpress with default plugins and themes' do
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
            wpadminpasswd => 'lolo',
            wpadminemail  => 'bar@foo.org',
          }
        }
      }
      EOS
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes  => true)
    end

    describe file('/var/spool/cron/crontabs/root') do
      it { should contain("7 * * * /usr/local/sbin/external_fact_wordpress.rb > /opt/puppetlabs/facter/facts.d/wordpress.yaml") }
    end

    describe file($wpcli_bin) do
      it { should be_file }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
      it { should be_mode 755 }
    end

    describe file($wp_root) do
      it { should be_directory }
      it { should be_owned_by 'wp' }
      it { should be_grouped_into 'wp' }
      it { should be_mode 750 }
    end

    describe file("#{$wp_root}/wp-config.php") do
      it { should be_file }
      it { should be_owned_by 'wp' }
      it { should be_grouped_into 'wp' }
      it { should be_mode 644 }
    end

    describe command('curl -L http://localhost') do
      its(:stdout) { should match /.*hola this wordpress instance is installed by puppet.*/ }
    end

    describe command("wp --allow-root --format=csv --path=#{$wp_root} --fields=language,status --status=active language core list") do
      its(:stdout) { should match /.*en_US,active.*/ }
    end
  end

  context 'with parameters about one wordpress with custon hour of external fact update' do
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
            wpadminpasswd => 'lolo',
            wpadminemail  => 'bar@foo.org',
          },
        }
      }
      EOS
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes  => true)
    end

    describe file('/var/spool/cron/crontabs/root') do
      it { should contain("3 * * * /usr/local/sbin/external_fact_wordpress.rb > /opt/puppetlabs/facter/facts.d/wordpress.yaml") }
    end
  end

  context 'with parameter about one wordpress with customized plugins and themes' do
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
            wpadminpasswd => 'lolo',
            wpadminemail  => 'bar@foo.org',
            wpresources   => {
              plugin => [
                {name => 'akismet', ensure => 'present'},
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
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes  => true)
    end
  
    describe file($wpcli_bin) do
      it { should be_file }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
      it { should be_mode 755 }
    end

    describe file($wp_root) do
      it { should be_directory }
      it { should be_owned_by 'wp' }
      it { should be_grouped_into 'wp' }
      it { should be_mode 750 }
    end

    describe file("#{$wp_root}/wp-config.php") do
      it { should be_file }
      it { should be_owned_by 'wp' }
      it { should be_grouped_into 'wp' }
      it { should be_mode 644 }
    end

    describe command('curl -L http://localhost') do
      its(:stdout) { should match /.*hola this wordpress instance is installed by puppet.*/ }
    end

    describe file("#{$wp_root}/wp-content/plugins/akismet") do
      it { should be_directory }
      it { should be_owned_by 'wp' }
      it { should be_grouped_into 'wp' }
      it { should be_mode 755 }
    end

    describe file("#{$wp_root}/wp-content/plugins/wp-piwik") do
      it { should be_directory }
      it { should be_owned_by 'wp' }
      it { should be_grouped_into 'wp' }
      it { should be_mode 755 }
    end

    describe file("#{$wp_root}/wp-content/plugins/hello.php") do
      it { should_not exist }
    end

    describe file("#{$wp_root}/wp-content/themes/twentyseventeen") do
      it { should be_directory }
      it { should be_owned_by 'wp' }
      it { should be_grouped_into 'wp' }
      it { should be_mode 755 }
    end

    describe file("#{$wp_root}/wp-content/themes/twentysixteen") do
      it { should_not exist }
    end
  end

  context 'with parameters about two wordpress instances with default plugins and themes' do
    it 'applies idempotently' do
      pp = <<-EOS
      class { 'wordpress': 
        settings => {
          'wp2.foo.org' => {
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
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes  => true)
    end
  
    describe file($wpcli_bin) do
      it { should be_file }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
      it { should be_mode 755 }
    end

    describe file($wp2_root) do
      it { should be_directory }
      it { should be_owned_by 'wp2' }
      it { should be_grouped_into 'wp2' }
      it { should be_mode 750 }
    end

    describe file("#{$wp2_root}/wp-config.php") do
      it { should be_file }
      it { should be_owned_by 'wp2' }
      it { should be_grouped_into 'wp2' }
      it { should be_mode 644 }
    end

    describe command("wp --allow-root --format=csv --path=#{$wp2_root} --fields=language,status --status=active language core list") do
      its(:stdout) { should match /.*fr_FR,active.*/ }
    end

    describe file($wp3_root) do
      it { should be_directory }
      it { should be_owned_by 'wp3' }
      it { should be_grouped_into 'wp3' }
      it { should be_mode 750 }
    end

    describe file("#{$wp3_root}/wp-config.php") do
      it { should be_file }
      it { should be_owned_by 'wp3' }
      it { should be_grouped_into 'wp3' }
      it { should be_mode 644 }
    end

    describe command("wp --allow-root --format=csv --path=#{$wp3_root} --fields=language,status --status=active language core list") do
      its(:stdout) { should match /.*en_US,active.*/ }
    end
  end

  context 'with buggy parameter' do
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
      apply_manifest(pp, :expect_failures => true)
    end
  end
 
end
