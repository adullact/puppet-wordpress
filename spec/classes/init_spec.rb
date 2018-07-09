require 'spec_helper'
describe 'wordpress' do
  context 'with default values for all parameters on Debian family' do
    let(:facts) { {os: { 'family' => 'Debian' }} }
    it { is_expected.to contain_class('wordpress') }
  end

  context 'with default values for all parameters on RedHat family' do
    let(:facts) { {os: { 'family' => 'RedHat' }} }
    it { is_expected.to contain_class('wordpress') }
  end

end
