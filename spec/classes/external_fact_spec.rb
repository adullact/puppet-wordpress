require 'spec_helper'

describe 'wordpress::external_fact' do
  let :default_params do
    {
      hour_fact_update: 9,
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
