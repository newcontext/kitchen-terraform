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
require "kitchen/verifier"
require "kitchen/terraform/config_attribute/color"
require "kitchen/terraform/config_attribute/groups"
require "kitchen/terraform/configurable"
require "kitchen/verifier/inspec"

# The verifier utilizes the {https://www.inspec.io/ InSpec infrastructure testing framework} to verify the behaviour and
# state of resources in the Terraform state.
#
# === Commands
#
# The following command-line commands are provided by the verifier.
#
# ==== kitchen verify
#
# A Test Kitchen instance is verified by iterating through the groups and executing the associated InSpec controls in a
# manner similar to the following command-line command.
#
#   inspec exec \
#     [--attrs=<terraform_outputs>] \
#     --backend=<ssh|local> \
#     [--no-color] \
#     [--controls=<group.controls>] \
#     --host=<group.hostnames.current|localhost> \
#     [--password=<group.password>] \
#     [--port=<group.port>] \
#     --profiles-path=test/integration/<suite> \
#     [--user=<group.username>] \
#
# === InSpec Profiles
#
# The {https://www.inspec.io/docs/reference/profiles/ InSpec profile} for a Test Kitchen suite must be defined under
# +./test/integration/<suite>/+.
#
# === Configuration Attributes
#
# The configuration attributes of the verifier control the behaviour of the InSpec runner. Within the
# {http://kitchen.ci/docs/getting-started/kitchen-yml Test Kitchen configuration file}, these attributes must be
# declared in the +verifier+ mapping along with the plugin name.
#
#   verifier:
#     name: terraform
#     a_configuration_attribute: some value
#
# ==== color
#
# {include:Kitchen::Terraform::ConfigAttribute::Color}
#
# ==== groups
#
# {include:Kitchen::Terraform::ConfigAttribute::Groups}
#
# @version 2
class ::Kitchen::Verifier::Terraform < ::Kitchen::Verifier::Inspec
  kitchen_verifier_api_version 2

  include ::Dry::Monads::Either::Mixin

  include ::Dry::Monads::Maybe::Mixin

  include ::Kitchen::Terraform::ConfigAttribute::Color

  include ::Kitchen::Terraform::ConfigAttribute::Groups

  include ::Kitchen::Terraform::Configurable

  # The verifier enumerates through each hostname of each group and verifies the associated InSpec controls.
  #
  # @example
  #   `kitchen verify suite-name`
  # @param state [::Hash] the mutable instance and verifier state.
  # @raise [::Kitchen::ActionFailed] if the result of the action is a failure.
  # @return [::Dry::Monads::Either] the result of the action.
  def call(state)
    Maybe(state.dig(:kitchen_terraform_output))
      .or do
        Left(
          "The Test Kitchen state does not include :kitchen_terraform_output; this implies that the " \
            "kitchen-terraform provisioner has not successfully converged"
        )
      end
      .bind do |output|
        ::Kitchen::Verifier::Terraform::EnumerateGroupsAndHostnames
          .call(
            groups: config_groups,
            output: ::Kitchen::Util.stringified_hash(output)
          ) do |group:, hostname:|
            state
              .store(
                :kitchen_terraform_group,
                group
              )
            state
              .store(
                :kitchen_terraform_hostname,
                hostname
              )
            info "Verifying host '#{hostname}' of group '#{group.fetch :name}'"
            super state
          end
      end
      .or do |failure|
        raise(
          ::Kitchen::ActionFailed,
          failure
        )
      end
  end

  private

  # Modifies the Inspec Runner options generated by the kitchen-inspec verifier to support the verification of each
  # group's hosts.
  #
  # @api private
  # @return [::Hash] Inspec Runner options.
  # @see https://github.com/chef/inspec/blob/master/lib/inspec/runner.rb ::Inspec::Runner
  def runner_options(transport, state = {}, platform = nil, suite = nil)
    super(transport, state, platform, suite)
      .tap do |options|
        ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerBackend
          .call(
            hostname: state.fetch(:kitchen_terraform_hostname),
            options: options
          )
        ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerHost
          .call(
            hostname: state.fetch(:kitchen_terraform_hostname),
            options: options
          )
        ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerPort
          .call(
            group: state.fetch(:kitchen_terraform_group),
            options: options
          )
        ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerSSHKey
          .call(
            group: state.fetch(:kitchen_terraform_group),
            options: options
          )
        ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerUser
          .call(
            group: state.fetch(:kitchen_terraform_group),
            options: options
          )
        ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerAttributes
          .call(
            group: state.fetch(:kitchen_terraform_group),
            output: ::Kitchen::Util.stringified_hash(state.fetch(:kitchen_terraform_output))
          )
          .bind do |attributes|
            options
              .store(
                :attributes,
                attributes
              )
          end
        ::Kitchen::Verifier::Terraform::ConfigureInspecRunnerControls
          .call(
            group: state.fetch(:kitchen_terraform_group),
            options: options
          )
      end
  end
end

require "kitchen/verifier/terraform/configure_inspec_runner_attributes"
require "kitchen/verifier/terraform/configure_inspec_runner_backend"
require "kitchen/verifier/terraform/configure_inspec_runner_controls"
require "kitchen/verifier/terraform/configure_inspec_runner_host"
require "kitchen/verifier/terraform/configure_inspec_runner_port"
require "kitchen/verifier/terraform/configure_inspec_runner_ssh_key"
require "kitchen/verifier/terraform/configure_inspec_runner_user"
require "kitchen/verifier/terraform/enumerate_groups_and_hostnames"
