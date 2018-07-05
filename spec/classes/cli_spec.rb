require 'spec_helper'

default_wpcli_ensure = 'present'

describe 'wordpress::cli' do
  let :default_params do
    {
      wpcli_bin: '/bin/wpcli',
      wpcli_url: 'http://foo.bar',
      ensure: default_wpcli_ensure.to_s,
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        default_params
      end

      it { is_expected.to compile }
    end
  end
end
