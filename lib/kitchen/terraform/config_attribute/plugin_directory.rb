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

require "kitchen/terraform/config_attribute"
require "kitchen/terraform/config_attribute_cacher"
require "kitchen/terraform/config_schemas/optional_string"
require "kitchen/terraform/file_path_config_attribute_definer"

module Kitchen
  module Terraform
    class ConfigAttribute
      # PluginDirectory adds the plugin_directory configuration attribute.
      module PluginDirectory
        class << self
          # A callback to define the configuration attribute which is invoked when this module is included in a plugin
          # class.
          #
          # @param plugin_class [Kitchen::Configurable] A plugin class.
          # @return [void]
          def included(plugin_class)
            ::Kitchen::Terraform::FilePathConfigAttributeDefiner.new(
              attribute: self,
              schema: ::Kitchen::Terraform::ConfigSchemas::OptionalString,
            ).define plugin_class: plugin_class
          end

          # @return [Symbol] the symbol corresponding to this attribute.
          def to_sym
            :plugin_directory
          end
        end

        extend ::Kitchen::Terraform::ConfigAttributeCacher

        # @return [nil]
        def config_plugin_directory_default_value
          nil
        end
      end
    end
  end
end
