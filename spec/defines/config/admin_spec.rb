require 'spec_helper'

describe 'wordpress::config::admin' do
  let(:title) { 'namevar' }
  let(:pre_condition) do
    needed_objects = <<-EOS
      class { 'wordpress::site' :
        wpcli_bin                => '/bin/wp',
	install_secret_directory => '/etc/foo',
      }
    EOS
    needed_objects
  end

  let(:params) do
    {
      wp_servername: 'www.foo.org',
      wp_root: '/var/foo',
      owner: 'wfoo',
      wp_admin_login: 'foo',
      wp_admin_passwd: 'secret',
      wp_admin_email: 'foo@bar.org',
      wp_admin_passwd_hash: 'hashsecret',
      wpcli_bin: '/bin/wp',
    }
  end


  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end
