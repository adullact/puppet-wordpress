require 'spec_helper'

describe 'wordpress::config::option' do
  let(:title) { 'namevar' }
  let(:params) do
    {
      wp_servername: 'www.foo.org',
      wp_root: '/var/foo',
      owner: 'wfoo',
      wp_option_name: 'fooname',
      wp_option_value: 'foovalue',
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
