require 'spec_helper'
describe 'Roles' do
  context 'with default values for all parameters' do
    it { should contain_class('Roles') }
  end
end
