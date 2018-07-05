require 'spec_helper_acceptance'

$wpcli_bin = '/usr/local/bin/wp'
$apache_root = '/var/www'
$wp_root = '/var/www/wordpress.foo.org'

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

  context 'with parameter about one wordpress with default plugins and themes' do
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
