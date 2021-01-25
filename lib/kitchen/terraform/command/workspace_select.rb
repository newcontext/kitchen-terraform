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

module Kitchen
  module Terraform
    module Command
      # WorkspaceSelect represents the <code>terraform workspace select</code> command.
      class WorkspaceSelect
        # #initialize prepares a new instance of the class.
        #
        # @param config [Hash] the configuration of the driver.
        # @option config [String] :workspace_name the name of the Terraform workspace.
        # @return [Kitchen::Terraform::Command::WorkspaceSelect]
        def initialize(config:)
          self.workspace_name = config.fetch :workspace_name
        end

        # @return [String] the command.
        def to_s
          "workspace select #{workspace_name}"
        end

        private

        attr_accessor :workspace_name
      end
    end
  end
end
