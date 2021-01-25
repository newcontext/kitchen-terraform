# frozen_string_literal: true

# Copyright 2016-2019 New Context, Inc.
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

require "kitchen"
require "kitchen/terraform/raise/action_failed"
require "kitchen/terraform/config_attribute/backend_configurations"
require "kitchen/terraform/config_attribute/client"
require "kitchen/terraform/config_attribute/color"
require "kitchen/terraform/config_attribute/command_timeout"
require "kitchen/terraform/config_attribute/lock_timeout"
require "kitchen/terraform/config_attribute/lock"
require "kitchen/terraform/config_attribute/parallelism"
require "kitchen/terraform/config_attribute/plugin_directory"
require "kitchen/terraform/config_attribute/root_module_directory"
require "kitchen/terraform/config_attribute/variable_files"
require "kitchen/terraform/config_attribute/variables"
require "kitchen/terraform/config_attribute/verify_version"
require "kitchen/terraform/configurable"
require "kitchen/terraform/driver/create"
require "kitchen/terraform/driver/destroy"
require "kitchen/terraform/version_verifier"
require "rubygems"
require "shellwords"

# This namespace is defined by Kitchen.
#
# @see http://www.rubydoc.info/gems/test-kitchen/Kitchen
module Kitchen
  # This namespace is defined by Kitchen.
  #
  # @see http://www.rubydoc.info/gems/test-kitchen/Kitchen/Driver
  module Driver
    # Terraform manages the {https://www.terraform.io/docs/state/index.html state} of the Terraform root module by shelling out and running
    # Terraform commands.
    #
    # This class implements the interface of Kitchen::Configurable which requires the following Reek suppressions:
    # :reek:MissingSafeMethod { exclude: [ finalize_config! ] }
    class Terraform < ::Kitchen::Driver::Base
      kitchen_driver_api_version 2

      no_parallel_for(
        :create,
        :converge,
        :setup,
        :destroy
      )

      include ::Kitchen::Terraform::ConfigAttribute::BackendConfigurations

      include ::Kitchen::Terraform::ConfigAttribute::Client

      include ::Kitchen::Terraform::ConfigAttribute::Color

      include ::Kitchen::Terraform::ConfigAttribute::CommandTimeout

      include ::Kitchen::Terraform::ConfigAttribute::Lock

      include ::Kitchen::Terraform::ConfigAttribute::LockTimeout

      include ::Kitchen::Terraform::ConfigAttribute::Parallelism

      include ::Kitchen::Terraform::ConfigAttribute::PluginDirectory

      include ::Kitchen::Terraform::ConfigAttribute::RootModuleDirectory

      include ::Kitchen::Terraform::ConfigAttribute::VariableFiles

      include ::Kitchen::Terraform::ConfigAttribute::Variables

      include ::Kitchen::Terraform::ConfigAttribute::VerifyVersion

      include ::Kitchen::Terraform::Configurable

      # Creates a Test Kitchen instance by initializing the working directory and creating a test workspace.
      #
      # @param _state [Hash] the mutable instance and driver state.
      # @raise [Kitchen::ActionFailed] if the result of the action is a failure.
      # @return [void]
      def create(_state)
        create_strategy.call
      rescue => error
        action_failed.call message: error.message
      end

      # Destroys a Test Kitchen instance by initializing the working directory, selecting the test workspace,
      # deleting the state, selecting the default workspace, and deleting the test workspace.
      #
      # @param _state [Hash] the mutable instance and driver state.
      # @raise [Kitchen::ActionFailed] if the result of the action is a failure.
      # @return [void]
      def destroy(_state)
        destroy_strategy.call
      rescue => error
        action_failed.call message: error.message
      end

      # #finalize_config! invokes the super implementation and then initializes the strategies.
      #
      # @param instance [Kitchen::Instance] an associated instance.
      # @raise [Kitchen::ClientError] if the instance is nil.
      # @return [self]
      # @see Kitchen::Configurable#finalize_config!
      def finalize_config!(instance)
        super instance
        self.create_strategy = ::Kitchen::Terraform::Driver::Create.new(
          config: config,
          logger: logger,
          version_requirement: version_requirement,
          workspace_name: workspace_name,
        )
        self.destroy_strategy = ::Kitchen::Terraform::Driver::Destroy.new(
          config: config,
          logger: logger,
          version_requirement: version_requirement,
          workspace_name: workspace_name,
        )

        self
      end

      # #initialize prepares a new instance of the class.
      #
      # @param config [Hash] the driver configuration.
      # @return [Kitchen::Driver::Terraform]
      def initialize(config = {})
        super config
        self.action_failed = ::Kitchen::Terraform::Raise::ActionFailed.new logger: logger
      end

      private

      attr_accessor :action_failed, :create_strategy, :destroy_strategy
    end
  end
end
