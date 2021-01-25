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
require "kitchen/terraform/command_executor"
require "kitchen/terraform/command/destroy"
require "kitchen/terraform/command/init"
require "kitchen/terraform/command/version"
require "kitchen/terraform/command/workspace_delete"
require "kitchen/terraform/command/workspace_new"
require "kitchen/terraform/command/workspace_select"
require "kitchen/terraform/verify_version"

module Kitchen
  module Terraform
    module Driver
      # Destroy implements the <code>kitchen destroy</code> command.
      class Destroy
        # #call executes the action.
        #
        # @raise [Kitchen::TransientFailure] if a command fails.
        # @return [self]
        def call
          verify_version.call command: version, options: options
          execute_workflow

          self
        end

        # #initialize prepares a new instance of the class.
        #
        # @param config [Hash] the configuration of the driver.
        # @param logger [Kitchen::Logger] a logger for logging messages.
        # @param version_requirement [Gem::VersionRequirement] the required version of the Terraform client.
        # @param workspace_name [String] the name of the Terraform workspace to select or to create.
        # @return [Kitchen::Terraform::Driver::Destroy]
        def initialize(config:, logger:, version_requirement:, workspace_name:)
          hash_config = config.to_hash.merge upgrade_during_init: false, workspace_name: workspace_name
          self.command_executor = ::Kitchen::Terraform::CommandExecutor.new(
            client: config.fetch(:client),
            logger: logger,
          )
          self.logger = logger
          self.options = { cwd: config.fetch(:root_module_directory), timeout: config.fetch(:command_timeout) }
          self.workspace_name = workspace_name
          self.destroy = ::Kitchen::Terraform::Command::Destroy.new config: config
          self.init = ::Kitchen::Terraform::Command::Init.new config: hash_config
          self.workspace_delete_test = ::Kitchen::Terraform::Command::WorkspaceDelete.new config: hash_config
          self.workspace_new_test = ::Kitchen::Terraform::Command::WorkspaceNew.new config: hash_config
          self.workspace_select_test = ::Kitchen::Terraform::Command::WorkspaceSelect.new config: hash_config
          self.workspace_select_default = ::Kitchen::Terraform::Command::WorkspaceSelect.new(
            config: hash_config.merge(workspace_name: "default"),
          )
          self.verify_version = ::Kitchen::Terraform::VerifyVersion.new(
            command_executor: command_executor,
            config: config,
            logger: logger,
            version_requirement: version_requirement,
          )
          self.version = ::Kitchen::Terraform::Command::Version.new
        end

        private

        attr_accessor(
          :command_executor,
          :destroy,
          :init,
          :logger,
          :options,
          :verify_version,
          :version,
          :workspace_delete_test,
          :workspace_name,
          :workspace_new_test,
          :workspace_select_default,
          :workspace_select_test,
        )

        def create_test_workspace
          logger.warn "Creating the #{workspace_name} Terraform workspace..."
          command_executor.run command: workspace_new_test, options: options do |standard_output:|
          end
          logger.warn "Finished creating the #{workspace_name} Terraform workspace."
        end

        def destroy_infrastructure
          logger.warn "Destroying the Terraform-managed infrastructure..."
          command_executor.run command: destroy, options: options do |standard_output:|
          end
          logger.warn "Finished destroying the Terraform-managed infrastructure."
        end

        def delete_test_workspace
          logger.warn "Deleting the #{workspace_name} Terraform workspace..."
          command_executor.run command: workspace_delete_test, options: options do |standard_output:|
          end
          logger.warn "Finished deleting the #{workspace_name} Terraform workspace."
        end

        def execute_workflow
          initialize_directory
          select_or_create_test_workspace
          destroy_infrastructure
          select_default_workspace
          delete_test_workspace
        end

        def initialize_directory
          logger.warn "Initializing the Terraform working directory..."
          command_executor.run command: init, options: options do |standard_output:|
          end
          logger.warn "Finished initializing the Terraform working directory."
        end

        def select_default_workspace
          logger.warn "Selecting the default Terraform workspace..."
          command_executor.run command: workspace_select_default, options: options do |standard_output:|
          end
          logger.warn "Finished selecting the default Terraform workspace."
        end

        def select_or_create_test_workspace
          logger.warn "Selecting the #{workspace_name} Terraform workspace..."
          command_executor.run command: workspace_select_test, options: options do |standard_output:|
          end
          logger.warn "Finished selecting the #{workspace_name} Terraform workspace."
        rescue ::Kitchen::TransientFailure
          create_test_workspace
        end
      end
    end
  end
end
