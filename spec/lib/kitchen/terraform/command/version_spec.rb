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

require "kitchen"
require "kitchen/terraform/command/version"
require "kitchen/terraform/shell_out"

::RSpec.describe ::Kitchen::Terraform::Command::Version do
  describe ".run" do
    let :output do
      "Terraform v1.2.3"
    end

    let :version do
      described_class.new
    end

    before do
      allow(::Kitchen::Terraform::ShellOut).to receive(:run_command).with(
        "terraform version",
        cwd: ::Dir.pwd,
        environment: kind_of(::Hash),
        timeout: 60_000,
      ).and_return output
    end

    specify "should yield the result of running `terraform version`" do
      expect do |block|
        described_class.run(&block)
      end.to yield_with_args version: version
    end
  end
end
