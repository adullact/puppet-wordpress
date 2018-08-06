require 'spec_helper'

describe 'wordpress::core::config' do
  let(:pre_condition) do
    needed_objects = <<-EOS
      class{ 'wordpress::external_fact' :
        hour_fact_update => 7,
      }
      wordpress::core::install { 'www.foo.org' :
        wp_servername  => 'www.foo.org',
        wp_root        => '/var/foo',
        owner          => 'wfoo',
        locale         => 'jp_JP',
        db_host        => '10.1.1.1',
        db_name        => 'wpdb',
        db_user        => 'wpuser',
        db_passwd      => 'secret',
        dbprefix       => 'wp1234',
        wp_title       => 'this is the title',
        wp_admin       => 'myadmin',
        wp_passwd      => 'mypassword',
        wp_mail        => 'bar@foo.org',
        wpselfupdate   => 'disabled',
        wpcli_bin      => '/bin/wp',
      }
    EOS
    needed_objects
  end

  let(:title) { 'namevar' }
  let(:params) do
    {
      wp_servername: 'www.foo.org',
      wp_root: '/var/foo',
      owner: 'wfoo',
      locale: 'jp_JP',
      db_host: '10.1.1.1',
      db_name: 'wpdb',
      db_user: 'wpuser',
      db_passwd: 'secret',
      dbprefix: 'wp1234',
      wp_title: 'this is the title',
      wp_admin: 'myadmin',
      wp_passwd: 'mypassword',
      wp_mail: 'bar@foo.org',
      wpselfupdate: 'disabled',
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
