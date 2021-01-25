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
require "kitchen/terraform/command_flag/var_file"
require "kitchen/terraform/command_flag/var"
require "shellwords"

module Kitchen
  module Terraform
    module Command
      # Validate is the class of objects which represent the +validate+ command.
      class Validate
        # #initialize prepares a new instance of the class.
        #
        # @param config [Hash] the configuration of the driver.
        # @option config [Boolean] :color a toggle of colored output from the Terraform client.
        # @option config [Array<String>] :variable_files a list of pathnames of Terraform variable files to evaluate.
        # @option config [Hash{String=>String}] :variables a mapping of Terraform variables to evaluate.
        # @return [Kitchen::Terraform::Command::Validate]
        def initialize(config:)
          self.color = ::Kitchen::Terraform::CommandFlag::Color.new enabled: config.fetch(:color)
          self.var_file = ::Kitchen::Terraform::CommandFlag::VarFile.new pathnames: config.fetch(:variable_files)
          self.var = ::Kitchen::Terraform::CommandFlag::Var.new arguments: config.fetch(:variables)
        end

        # @return [String] the command with flags.
        def to_s
          "validate " \
          "#{color} " \
          "#{var} " \
          "#{var_file}"
        end

        private

        attr_accessor(
          :color,
          :var_file,
          :var,
        )
      end
    end
  end
end
