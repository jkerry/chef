#
# Author:: Adam Jacob (<adam@chef.io>)
# Copyright:: Copyright 2008-2016, Chef Software Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'spec_helper'

describe Chef::Provider::UserRights do
  before(:each) do
    @node = Chef::Node.new
    @events = Chef::EventDispatch::Dispatcher.new
    @run_context = Chef::RunContext.new(@node, {}, @events)

    @new_resource = Chef::Resource::UserRights.new('conan')
    @new_resource.rights %w(SeServiceLogonRight SeInteractiveLogonRight)

    @current_resource = Chef::Resource::UserRights.new('conan')
    @current_resource.rights %w(SeServiceLogonRight SeInteractiveLogonRight)

    @provider = Chef::Provider::UserRights.new(@new_resource, @run_context)
    @provider.current_resource = @current_resource
  end

  describe 'when first created' do
    it 'assume the user exists by default' do
      expect(@provider.user_exists).to eql(true)
    end
  end

  describe 'executing load_current_resource' do
    before(:each) do
      @node = Chef::Node.new
      allow(Chef::Resource::UserRights).to receive(:new).and_return(
        @current_resource)
    end
  end
end
