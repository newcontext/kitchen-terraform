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

require "kitchen/terraform/command_flag/color"
require "kitchen/terraform/command_flag/lock_timeout"
require "kitchen/terraform/command_flag/var_file"
require "kitchen/terraform/command_flag/var"
require "shellwords"

module Kitchen
  module Terraform
    module Command
      # Apply is the class of objects which represent the +apply+ command.
      class Apply
        # #initialize prepares a new instance of the class.
        #
        # @param config [Hash] the configuration of the driver.
        # @option config [Boolean] :color a toggle of colored output from the Terraform client.
        # @option config [Boolean] :lock a toggle of locking for the Terraform state file.
        # @option config [Integer] :lock_timeout the number of seconds that the Terraform client will wait for a lock
        #   on the state to be obtained during operations.
        # @option config [Integer] :parallelism the number of concurrent operations to use while Terraform walks the
        #   resource graph.
        # @option config [Array<String>] :variable_files a list of pathnames of Terraform variable files to evaluate.
        # @option config [Hash{String=>String}] :variables a mapping of Terraform variables to evaluate.
        # @return [Kitchen::Terraform::Command::Apply]
        def initialize(config:)
          self.color = ::Kitchen::Terraform::CommandFlag::Color.new enabled: config.fetch(:color)
          self.lock = config.fetch :lock
          self.lock_timeout = ::Kitchen::Terraform::CommandFlag::LockTimeout.new duration: config.fetch(:lock_timeout)
          self.parallelism = config.fetch :parallelism
          self.var_file = ::Kitchen::Terraform::CommandFlag::VarFile.new pathnames: config.fetch(:variable_files)
          self.var = ::Kitchen::Terraform::CommandFlag::Var.new arguments: config.fetch(:variables)
        end

        # @return [String] the command with flags.
        def to_s
          "apply " \
          "-auto-approve " \
          "-lock=#{lock} " \
          "#{lock_timeout} " \
          "-input=false " \
          "#{color} " \
          "-parallelism=#{parallelism} " \
          "-refresh=true " \
          "#{var} " \
          "#{var_file}"
        end

        private

        attr_accessor(
          :color,
          :lock,
          :lock_timeout,
          :parallelism,
          :var_file,
          :var,
        )
      end
    end
  end
end
