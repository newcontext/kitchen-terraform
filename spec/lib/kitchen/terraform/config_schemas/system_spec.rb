# frozen_string_literal: true

# Copyright 2016-2021 Copado NCS LLC
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

require "kitchen/terraform/config_schemas/system"

::RSpec.describe Kitchen::Terraform::ConfigSchemas::System do
  subject do
    described_class
  end

  shared_examples "a string" do
    specify "the input must associate the attribute with a string" do
      expect(subject.call({ attribute => 123 }).errors).to include attribute => ["must be a failing test"]
    end

    specify "the input must associate the attribute with a nonempty string" do
      expect(subject.call(attribute => "").errors).to include attribute => ["must be filled"]
    end
  end

  shared_examples "a required string" do
    specify "the input must include the attribute" do
      expect(subject.call({}).errors).to include attribute => ["is missing"]
    end

    it_behaves_like "a string"
  end

  shared_examples "an optional array of strings" do
    specify "the input may include the attribute" do
      expect(subject.call({}).errors).not_to include attribute => ["is missing"]
    end

    specify "the input must associate the attribute with an array" do
      expect(subject.call(attribute => 123).errors).to include attribute => ["must be an array"]
    end

    specify "the input must associate the attribute with an array which includes strings" do
      expect(subject.call(attribute => [123]).errors).to include attribute => { 0 => ["must be a string"] }
    end

    specify "the input must associate the attribute with an array which includes nonempty strings" do
      expect(subject.call(attribute => [""]).errors).to include attribute => { 0 => ["must be filled"] }
    end
  end

  shared_examples "an optional boolean" do
    specify "the input may include the attribute" do
      expect(subject.call({}).errors).not_to include attribute => ["is missing"]
    end

    specify "the input must associate the attribute with a boolean" do
      expect(subject.call(attribute => 123).errors).to include attribute => ["must be boolean"]
    end
  end

  shared_examples "an optional integer" do
    specify "the input may include the attribute" do
      expect(subject.call({}).errors).not_to include attribute => ["is missing"]
    end

    specify "the input must associate the attribute with an integer" do
      expect(subject.call({ attribute => "abc" }).errors).to include attribute => ["must be an integer"]
    end
  end

  shared_examples "an optional string" do
    specify "the input may include the attribute" do
      expect(subject.call({}).errors).not_to include attribute => ["is missing"]
    end

    it_behaves_like "a string"
  end

  describe ".call" do
    describe ":name" do
      let :attribute do
        :name
      end

      it_behaves_like "a required string"
    end

    describe ":backend" do
      let :attribute do
        :backend
      end

      it_behaves_like "a required string"
    end

    specify "the input may include :attrs_outputs" do
      expect(subject.call({}).errors).not_to include attrs_outputs: ["is missing"]
    end

    specify "the input must associate :attrs_outputs with a hash" do
      expect(subject.call(attrs_outputs: 123).errors).to include attrs_outputs: ["must be a hash"]
    end

    describe ":attrs" do
      let :attribute do
        :attrs
      end

      it_behaves_like "an optional array of strings"
    end

    describe ":backend_cache" do
      let :attribute do
        :backend_cache
      end

      it_behaves_like "an optional boolean"
    end

    describe ":bastion_host" do
      let :attribute do
        :bastion_host
      end

      it_behaves_like "an optional string"
    end

    describe ":bastion_host_output" do
      let :attribute do
        :bastion_host_output
      end

      it_behaves_like "an optional string"
    end

    describe ":bastion_port" do
      let :attribute do
        :bastion_port
      end

      it_behaves_like "an optional integer"
    end

    describe ":bastion_user" do
      let :attribute do
        :bastion_user
      end

      it_behaves_like "an optional string"
    end

    describe ":controls" do
      let :attribute do
        :controls
      end

      it_behaves_like "an optional array of strings"
    end

    describe ":enable_password" do
      let :attribute do
        :enable_password
      end

      it_behaves_like "an optional string"
    end

    describe ":hosts" do
      let :attribute do
        :hosts
      end

      it_behaves_like "an optional array of strings"
    end

    describe ":hosts_output" do
      let :attribute do
        :hosts_output
      end

      it_behaves_like "an optional string"
    end

    describe ":key_files" do
      let :attribute do
        :key_files
      end

      it_behaves_like "an optional array of strings"
    end

    describe ":profile_locations" do
      let :attribute do
        :profile_locations
      end

      it_behaves_like "an optional array of strings"
    end

    describe ":password" do
      let :attribute do
        :password
      end

      it_behaves_like "an optional string"
    end

    describe ":path" do
      let :attribute do
        :path
      end

      it_behaves_like "an optional string"
    end

    describe ":port" do
      let :attribute do
        :port
      end

      it_behaves_like "an optional integer"
    end

    describe ":proxy_command" do
      let :attribute do
        :proxy_command
      end

      it_behaves_like "an optional string"
    end

    describe ":reporter" do
      let :attribute do
        :reporter
      end

      it_behaves_like "an optional array of strings"
    end

    describe ":self_signed" do
      let :attribute do
        :self_signed
      end

      it_behaves_like "an optional boolean"
    end

    describe ":shell" do
      let :attribute do
        :shell
      end

      it_behaves_like "an optional boolean"
    end

    describe ":shell_command" do
      let :attribute do
        :shell_command
      end

      it_behaves_like "an optional string"
    end

    describe ":shell_options" do
      let :attribute do
        :shell_options
      end

      it_behaves_like "an optional string"
    end

    describe ":show_progress" do
      let :attribute do
        :show_progress
      end

      it_behaves_like "an optional boolean"
    end

    describe ":ssl" do
      let :attribute do
        :ssl
      end

      it_behaves_like "an optional boolean"
    end

    describe ":sudo" do
      let :attribute do
        :sudo
      end

      it_behaves_like "an optional boolean"
    end

    describe ":sudo_command" do
      let :attribute do
        :sudo_command
      end

      it_behaves_like "an optional string"
    end

    describe ":sudo_options" do
      let :attribute do
        :sudo_options
      end

      it_behaves_like "an optional string"
    end

    describe ":sudo_password" do
      let :attribute do
        :sudo_password
      end

      it_behaves_like "an optional string"
    end

    describe ":user" do
      let :attribute do
        :user
      end

      it_behaves_like "an optional string"
    end

    describe ":vendor_cache" do
      let :attribute do
        :vendor_cache
      end

      it_behaves_like "an optional string"
    end
  end
end
