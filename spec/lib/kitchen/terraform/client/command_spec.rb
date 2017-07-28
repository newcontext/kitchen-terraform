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

require "kitchen/terraform/client/command"
require "kitchen/terraform/client/options/force_copy"
require "kitchen/terraform/client/options/var"
require "mixlib/shellout"
require "support/dry/monads/either_matchers"
require "support/kitchen/terraform/client/command_context"

::RSpec.describe ::Kitchen::Terraform::Client::Command do
  let :described_instance do
    described_class.new(
      logger: [],
      options: [
        ::Kitchen::Terraform::Client::Options::ForceCopy.new,
        ::Kitchen::Terraform::Client::Options::Var.new(
          name: "name",
          value: "value"
        )
      ],
      subcommand: "subcommand",
      target: "target",
      timeout: 1234
    )
  end

  shared_examples "the command experiences an error" do
    it do
      is_expected.to result_in_failure.with_the_value /`terraform subcommand target` failed: '.+'/
    end
  end

  describe "#run" do
    subject do
      described_instance.run
    end

    context "when a permissions error occurs" do
      include_context "Kitchen::Terraform::Client::Command", error: ::Errno::EACCES,
                                                             subcommand: "subcommand"

      it_behaves_like "the command experiences an error"
    end

    context "when an entry error occurs" do
      include_context "Kitchen::Terraform::Client::Command", error: ::Errno::ENOENT,
                                                             subcommand: "subcommand"

      it_behaves_like "the command experiences an error"
    end

    context "when a timeout error occurs" do
      include_context "Kitchen::Terraform::Client::Command", error: ::Mixlib::ShellOut::CommandTimeout,
                                                             subcommand: "subcommand"

      it_behaves_like "the command experiences an error"
    end

    context "when the command exits with a nonzero value" do
      include_context "Kitchen::Terraform::Client::Command", subcommand: "subcommand"

      it_behaves_like "the command experiences an error"
    end

    context "when the command exits with a zero value" do
      include_context "Kitchen::Terraform::Client::Command", exit_code: 0,
                                                             subcommand: "subcommand"

      it do
        is_expected.to result_in_success.with_the_value "stdout"
      end
    end
  end
end
