require 'spec_helper'

describe 'wordpress::core' do
  let :default_params do
    {
      wpcli_bin: '/bin/wpcli',
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
