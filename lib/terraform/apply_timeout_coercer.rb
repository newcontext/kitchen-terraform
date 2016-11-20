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

require 'forwardable'
require_relative 'simple_coercer'

module Terraform
  # A coercer for the [:apply_timeout] value
  class ApplyTimeoutCoercer
    extend Forwardable

    def_delegator :coercer, :coerce

    private

    attr_accessor :coercer

    def initialize(configurable:)
      self.coercer = SimpleCoercer.new configurable: configurable,
                                       expected: 'an integer',
                                       method: method(:Integer)
    end
  end
end
