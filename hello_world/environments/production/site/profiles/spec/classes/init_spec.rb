require 'spec_helper'
describe 'Profile' do
  context 'with default values for all parameters' do
    it { should contain_class('Profile') }
  end
end
