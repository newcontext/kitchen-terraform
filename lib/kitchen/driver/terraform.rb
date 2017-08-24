# frozen_string_literal: true

# Copyright 2016 New Context Services, Inc.
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

require "dry/monads"
require "json"
require "kitchen"
require "kitchen/terraform/clear_directory"
require "kitchen/terraform/create_directories"
require "kitchen/terraform/client/command"
require "kitchen/terraform/client/options"
require "kitchen/terraform/define_array_of_strings_config_attribute"
require "kitchen/terraform/define_hash_of_symbols_and_strings_config_attribute"
require "kitchen/terraform/define_config_attribute"
require "kitchen/terraform/define_integer_config_attribute"
require "kitchen/terraform/define_optional_file_path_config_attribute"
require "kitchen/terraform/define_string_config_attribute"
require "terraform/configurable"

# The kitchen-terraform driver is the bridge between Test Kitchen and Terraform. It manages the state of the configured
# root Terraform module by invoking its workflow in a constructive or destructive manner.
#
# === Configuration
#
# ==== Example .kitchen.yml snippet
#
#   driver:
#     name: terraform
#     command_timeout: 1000
#     color: false
#     directory: /directory/containing/terraform/configuration
#     parallelism: 2
#     state: /terraform/state
#     variable_files:
#       - /first/terraform/variable/file
#       - /second/terraform/variable/file
#     variables:
#       variable_name: variable_value
#
# ==== Attributes
#
# ===== color
#
# Description:: Toggle to enable or disable colored output from the Terraform CLI commands.
#
# Type:: Boolean
#
# Status:: Optional
#
# Default:: +true+ if the Test Kitchen process is associated with a terminal device (tty); +false+ if it is not.
#
# ===== command_timeout
#
# Description:: The number of seconds to wait for the Terraform CLI commands to finish.
#
# Type:: Integer
#
# Status:: Optional
#
# Default:: +600+
#
# ===== directory
#
# Description:: The path of the directory containing the root Terraform module to be tested.
#
# Type:: String
#
# Status:: Optional
#
# Default:: The working directory of the Test Kitchen process.
#
# ===== parallelism
#
# Description:: The maximum number of concurrent operations to allow while walking the resource graph for the Terraform
#               CLI apply commands.
# Type:: Integer
#
# Status:: Optional
#
# Default:: +10+
#
# ===== plugin_directory
#
# Description:: The path of the directory containing customized Terraform provider plugins to install in place of the
#               official Terraform provider plugins.
#
# Type:: String
#
# Status:: Optional
#
# ===== state
#
# Description:: The path of the Terraform state that will be generated and managed.
#
# Type:: String
#
# Status:: Optional
#
# Default:: A descendant of the working directory of the Test Kitchen process:i
#           +".kitchen/kitchen-terraform/<suite_name>/terraform.tfstate"+.
#
# ===== variable_files
#
# Description:: A collection of paths of Terraform variable files to be evaluated during the application of Terraform
#               state changes.
#
# Type:: Array
#
# Status:: Optional
#
# Default:: +[]+
#
# ===== variables
#
# Description:: A mapping of Terraform variable names and values to be overridden during the application of Terraform
#               state changes.
#
# Type:: Hash
#
# Status:: Optional
#
# Default:: +{}+
#
# @see https://en.wikipedia.org/wiki/Working_directory Working directory
# @see https://www.terraform.io/docs/commands/init.html#plugin-installation Terraform plugin installation
# @see https://www.terraform.io/docs/configuration/variables.html Terraform variables
# @see https://www.terraform.io/docs/internals/graph.html Terraform resource graph
# @see https://www.terraform.io/docs/state/index.html Terraform state
# @version 2
class ::Kitchen::Driver::Terraform < ::Kitchen::Driver::Base
  kitchen_driver_api_version 2

  no_parallel_for

  ::Kitchen::Terraform::DefineHashOfSymbolsAndStringsConfigAttribute.call(
    attribute: :backend_configurations,
    plugin_class: self
  )

  ::Kitchen::Terraform::DefineIntegerConfigAttribute.call attribute: :command_timeout,
                                                          plugin_class: self do
    600
  end

  ::Kitchen::Terraform::DefineConfigAttribute.call(
    attribute: :color,
    initialize_default_value: lambda do |_plugin|
      ::Kitchen.tty?
    end,
    plugin_class: self,
    schema: lambda do
      required(:value).filled :bool?
    end
  )

  ::Kitchen::Terraform::DefineStringConfigAttribute.call attribute: :directory,
                                                         expand_path: true,
                                                         plugin_class: self do
    "."
  end

  ::Kitchen::Terraform::DefineStringConfigAttribute.call attribute: :lock_timeout,
                                                         plugin_class: self do
    "0s"
  end

  ::Kitchen::Terraform::DefineIntegerConfigAttribute.call attribute: :parallelism,
                                                          plugin_class: self do
    10
  end

  ::Kitchen::Terraform::DefineOptionalFilePathConfigAttribute.call(
    attribute: :plugin_directory,
    plugin_class: self
  )

  ::Kitchen::Terraform::DefineStringConfigAttribute.call attribute: :state,
                                                         expand_path: true,
                                                         plugin_class: self do |plugin|
    plugin.instance_pathname filename: "terraform.tfstate"
  end

  ::Kitchen::Terraform::DefineArrayOfStringsConfigAttribute.call attribute: :variable_files,
                                                                 expand_path: true,
                                                                 plugin_class: self do
    []
  end

  ::Kitchen::Terraform::DefineHashOfSymbolsAndStringsConfigAttribute.call(
    attribute: :variables,
    plugin_class: self
  )

  include ::Dry::Monads::Either::Mixin

  include ::Dry::Monads::Try::Mixin

  include ::Terraform::Configurable

  # The driver invokes its constructive workflow.
  #
  # 1. Create the instance directory: `.kitchen/kitchen-terraform/<suite>-<platform>`
  # 2. Clear the instance directory of Terraform configuration files
  # 3. Execute `terraform init` in the instance directory
  # 4. Execute `terraform validate` in the instance directory
  # 5. Execute `terraform apply` in the instance directory
  #
  # @example
  #   `kitchen help create`
  # @example
  #   `kitchen create suite-name`
  # @note The user must ensure that different suites utilize separate Terraform state files if they are to run
  #       the create action concurrently.
  # @param _state [::Hash] the mutable instance and driver state; this parameter is ignored.
  # @raise [::Kitchen::ActionFailed] if the result of the action is a failure.
  def create(_state)
    workflow do
      run_apply
    end
  end

  # The driver invokes its destructive workflow.
  #
  # 1. Create the instance directory: `.kitchen/kitchen-terraform/<suite>-<platform>`
  # 2. Clear the instance directory of Terraform configuration files
  # 3. Execute `terraform init` in the instance directory
  # 4. Execute `terraform validate` in the instance directory
  # 5. Execute `terraform destroy` in the instance directory
  #
  # @example
  #   `kitchen help destroy`
  # @example
  #   `kitchen destroy suite-name`
  # @note The user must ensure that different suites utilize separate Terraform state files if they are to run
  #       the destroy action concurrently.
  # @param state [::Hash] the mutable instance and driver state.
  # @raise [::Kitchen::ActionFailed] if the result of the action is a failure.
  def destroy(_state)
    workflow do
      run_destroy
    end
  end

  # The driver parses the client output as JSON.
  #
  # @return [::Dry::Monads::Either] the result of the Terraform Client Output function.
  # @see ::Kitchen::Terraform::Client::Output
  def output
    ::Kitchen::Terraform::Client::Command.output(
      logger: debug_logger,
      options:
        ::Kitchen::Terraform::Client::Options
          .new
          .json
          .state(path: config_state),
      timeout: config_command_timeout,
      working_directory: instance_directory
    ).bind do |command|
      Try ::JSON::ParserError do
        ::JSON.parse command.output
      end.to_either
    end.or do |error|
      Left "parsing Terraform client output as JSON failed\n#{error}"
    end
  end

  # The driver verifies that the client version is supported.
  #
  # @raise [::Kitchen::UserError] if the version is not supported.
  # @see ::Kitchen::Driver::Terraform::VerifyClientVersion
  # @see ::Kitchen::Terraform::Client::Version
  def verify_dependencies
    ::Kitchen::Terraform::Client::Command.version(
      logger: debug_logger,
      working_directory: ::Dir.pwd
    ).bind do |command|
      self.class::VerifyClientVersion.call version: command.output
    end.bind do |verified_client_version|
      Right logger.warn verified_client_version
    end.or do |failure|
      raise ::Kitchen::UserError, failure
    end
  end

  private

  # @api private
  def prepare_instance_directory
    ::Kitchen::Terraform::CreateDirectories
      .call(
        directories: [instance_directory]
      )
      .bind do |created_directories|
        logger.debug created_directories
        ::Kitchen::Terraform::ClearDirectory
          .call(
            directory: instance_directory,
            files: [
              "*.tf",
              "*.tf.json"
            ]
          )
      end
      .bind do |cleared_directory|
        Right logger.debug cleared_directory
      end
  end

  # Runs the apply subcommand.
  #
  # @api private
  # @return [::Dry::Monads::Either] the result of the apply subcommand.
  # @see ::Kitchen::Terraform::Client::Command#apply
  def run_apply
    ::Kitchen::Terraform::Client::Command
      .apply(
        logger: logger,
        options:
          ::Kitchen::Terraform::Client::Options
            .new
            .enable_lock
            .lock_timeout(duration: config_lock_timeout)
            .disable_input
            .enable_auto_approve
            .maybe_no_color(toggle: !config_color)
            .parallelism(concurrent_operations: config_parallelism)
            .enable_refresh
            .state(path: config_state)
            .state_out(path: config_state)
            .vars(keys_and_values: config_variables)
            .var_files(paths: config_variable_files),
        timeout: config_command_timeout,
        working_directory: instance_directory
      )
  end

  # Runs the destroy subcommand.
  #
  # @api private
  # @return [::Dry::Monads::Either] the result of the destroy subcommand.
  # @see ::Kitchen::Terraform::Client::Command#destroy
  def run_destroy
    ::Kitchen::Terraform::Client::Command
      .destroy(
        logger: logger,
        options:
          ::Kitchen::Terraform::Client::Options
            .new
            .enable_lock
            .lock_timeout(duration: config_lock_timeout)
            .disable_input
            .maybe_no_color(toggle: !config_color)
            .parallelism(concurrent_operations: config_parallelism)
            .enable_refresh
            .state(path: config_state)
            .state_out(path: config_state)
            .vars(keys_and_values: config_variables)
            .var_files(paths: config_variable_files)
            .force,
        timeout: config_command_timeout,
        working_directory: instance_directory
      )
  end

  # Runs the init subcommand.
  #
  # @api private
  # @return [::Dry::Monads::Either] the result of the init subcommand.
  # @see ::Kitchen::Terraform::Client::Command#init
  def run_init
    ::Kitchen::Terraform::Client::Command
      .init(
        logger: logger,
        options:
          ::Kitchen::Terraform::Client::Options
            .new
            .disable_input
            .enable_lock
            .lock_timeout(duration: config_lock_timeout)
            .maybe_no_color(toggle: !config_color)
            .upgrade
            .from_module(source: config_directory)
            .enable_backend
            .force_copy
            .backend_configs(keys_and_values: config_backend_configurations)
            .enable_get
            .maybe_plugin_dir(path: config_plugin_directory),
        timeout: config_command_timeout,
        working_directory: instance_directory
      )
  end

  # Runs the validate subcommand.
  #
  # @api private
  # @return [::Dry::Monads::Either] the result of the validate subcommand.
  # @see ::Kitchen::Terraform::Client::Command#validate
  def run_validate
    ::Kitchen::Terraform::Client::Command
      .validate(
        logger: logger,
        options:
          ::Kitchen::Terraform::Client::Options
            .new
            .enable_check_variables
            .maybe_no_color(toggle: !config_color)
            .vars(keys_and_values: config_variables)
            .var_files(paths: config_variable_files),
        timeout: config_command_timeout,
        working_directory: instance_directory
      )
  end

  # The path to the Test Kitchen suite instance directory.

  # @api private
  # @return [::String] the path to the Test Kitchen suite instance directory.
  def instance_directory
    @instance_directory ||= instance_pathname filename: "/"
  end

  # Prepares the instance directory, runs init and validate, and then yields for a subcommand.
  #
  # @api private
  # @raise [::Kitchen::ActionFailed] if the result of the action is a failure.
  def workflow
    prepare_instance_directory
      .bind do
        run_init
      end
      .bind do
        run_validate
      end
      .bind do
        yield
      end
      .or do |failure|
        raise(
          ::Kitchen::ActionFailed,
          failure
        )
      end
  end
end

require "kitchen/driver/terraform/verify_client_version"
