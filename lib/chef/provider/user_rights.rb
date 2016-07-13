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

require "chef/provider"
require "chef/mixin/command"
require "etc"

class Chef
  class Provider
    class UserRights < Chef::Provider

      attr_accessor :user_exists

      def initialize(new_resource, run_context)
        super
        @user_exists = true
      end

      def load_current_resource
        @current_resource = Chef::Resource::UserRights.new(@new_resource.name)
        @current_resource.username(@new_resource.username)

        begin
          user_info = Etc.getpwnam(@new_resource.username)
        rescue ArgumentError
          @user_exists = false
          Chef::Log.debug("#{@new_resource} user does not exist")
          user_info = nil
        end

        if user_info
          @current_resource.rights = Chef::ReservedNames::Win32::Security.get_account_right(@new_resource.username)
        end
        @current_resource
      end

      # def define_resource_requirements
      #   requirements.assert(:create, :modify, :manage, :lock, :unlock) do |a|
      #     a.assertion { @group_name_resolved }
      #     a.failure_message Chef::Exceptions::User, "Couldn't lookup integer GID for group name #{@new_resource.gid}"
      #     a.whyrun "group name #{@new_resource.gid} does not exist.  This will cause group assignment to fail.  Assuming this group will have been created previously."
      #   end
      #   requirements.assert(:all_actions) do |a|
      #     a.assertion { @shadow_lib_ok }
      #     a.failure_message Chef::Exceptions::MissingLibrary, "You must have ruby-shadow installed for password support!"
      #     a.whyrun "ruby-shadow is not installed. Attempts to set user password will cause failure.  Assuming that this gem will have been previously installed." +
      #       "Note that user update converge may report false-positive on the basis of mismatched password. "
      #   end
      #   requirements.assert(:modify, :lock, :unlock) do |a|
      #     a.assertion { @user_exists }
      #     a.failure_message(Chef::Exceptions::User, "Cannot modify user #{@new_resource.username} - does not exist!")
      #     a.whyrun("Assuming user #{@new_resource.username} would have been created")
      #   end
      # end

      # Check to see if the user needs any changes
      #
      # === Returns
      # <true>:: If a change is required
      # <false>:: If the users are identical
      # def compare_user
      #   changed = [ :comment, :home, :shell, :password ].select do |user_attrib|
      #     !@new_resource.send(user_attrib).nil? && @new_resource.send(user_attrib) != @current_resource.send(user_attrib)
      #   end
      #
      #   changed += [ :uid, :gid ].select do |user_attrib|
      #     !@new_resource.send(user_attrib).nil? && @new_resource.send(user_attrib).to_s != @current_resource.send(user_attrib).to_s
      #   end
      #
      #   changed.any?
      # end

      def action_create
        unless @user_exists
          converge_by("create user rights #{@new_resource.username}") do
            create_user_rights
            Chef::Log.info(
              "#{@new_resource} rights applied to #{@new_resource.username}")
          end
        end
      end

      def action_remove
        if @user_exists
          converge_by("remove user rights for #{@new_resource.username}") do
            remove_user_rights
            Chef::Log.info(
              "#{@new_resource} rights removed from #{@new_resource.username}")
          end
        end
      end
    end
  end
end
