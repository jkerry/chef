#
# Author:: John Kerry (<john@kerryhouse.net>)
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

require "spec_helper"

describe Chef::Resource::UserRights, "initialize" do
  before(:each) do
    @resource = Chef::Resource::UserRights.new("cthulhu")
  end

  it "should create a new Chef::Resource::UserRights" do
    expect(@resource).to be_a_kind_of(Chef::Resource)
    expect(@resource).to be_a_kind_of(Chef::Resource::UserRights)
  end

  it "should set the resource_name to :user_rights" do
    expect(@resource.resource_name).to eql(:user_rights)
  end

  it "should set the username to the name initialize argument" do
    expect(@resource.username).to eql("cthulhu")
  end

  it "should set the rights to an empty array" do
    expect(@resource.rights).to eql([])
  end

  it "should have :create as a default action" do
    expect(@resource.action).to eql([:create])
  end

  %w{create remove set}.each do |action|
    it "should allow action #{action}" do
      expect(@resource.allowed_actions.detect { |a| a == action.to_sym }).to eql(action.to_sym)
    end
  end
end

describe Chef::Resource::UserRights, "rights" do
  before(:each) do
    @resource = Chef::Resource::UserRights.new("cthulhu")
  end

  it "should allow an array of strings" do
    @resource.send("rights", ["Conan"])
    expect(@resource.send("rights")).to eql(["Conan"])
  end

  it "should not allow a hash of strings" do
    expect {@resource.send("rights", {:conan => "What is best in life?"}) }.to raise_error(ArgumentError)
  end
end
