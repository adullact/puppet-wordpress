require 'spec_helper'

describe 'wordpress::core::update' do
  let(:pre_condition) do
    needed_objects = <<-EOS
      class{ 'wordpress::external_fact' :
        hour_fact_update => 7,
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
      wpselfupdate: 'disabled',
      wpcli_bin: '/bin/wp',
      wparchives_path: '/var/fooarchives',
  }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end
