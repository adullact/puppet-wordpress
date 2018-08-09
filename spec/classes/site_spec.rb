require 'spec_helper'

describe 'wordpress::site' do
  let :params do
    {
      wpcli_bin: '/bin/wpcli',
      install_secret_directory: '/etc/foo',
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end
