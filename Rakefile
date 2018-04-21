# frozen_string_literal: true

require "bundler/gem_tasks"
require "digest"
require "open-uri"
require "pathname"
require "uri"
require "zip"

def binstub(name:)
  ::File
    .expand_path(
      "../bin/#{name}",
      __FILE__
    )
end

def download_terraform(sha256_sum:, version:)
  executable =
    ::Pathname
      .new("terraform")
      .expand_path

  uri =
    ::URI
      .parse(
        "https://releases.hashicorp.com/terraform/#{version}/terraform_#{version}_linux_amd64.zip"
      )

  puts "Downloading Terraform archive from #{uri}"

  uri
    .open do |archive|
      ::Digest::SHA256
        .file(archive.path)
        .hexdigest
        .==(sha256_sum) or
        raise "Downloaded Terraform archive has an unexpected SHA256 sum"

      puts "Extracting executable to #{executable}"

      ::Zip::File
        .open archive.path do |zip_file|
          zip_file
            .glob("terraform")
            .first
            .extract executable
        end

      executable.chmod 0o0544
      yield directory: executable.dirname
    end
ensure
  executable.unlink
end

def rspec_binstub
  binstub name: "rspec"
end

def kitchen_binstub
  binstub name: "kitchen"
end

namespace :tests do
  namespace :unit do
    desc "Run unit tests"

    task :run do
      sh "#{rspec_binstub} --backtrace"
    end
  end

  namespace :integration do
    desc "Run integration tests"

    task(
      :run,
      [
        :terraform_version,
        :terraform_sha256_sum
      ]
    ) do |_, arguments|
      arguments
        .with_defaults(
          terraform_version: "0.11.7",
          terraform_sha256_sum: "6b8ce67647a59b2a3f70199c304abca0ddec0e49fd060944c26f666298e23418"
        )

      download_terraform(
        sha256_sum: arguments.terraform_sha256_sum,
        version: arguments.terraform_version
      ) do |directory:|
        ::Dir
          .chdir "integration/docker_provider" do
            sh "KITCHEN_LOG=debug PATH=#{directory}:$PATH #{kitchen_binstub} test"
          end

        ::Dir
          .chdir "integration/no_outputs_defined" do
            sh "KITCHEN_LOG=debug PATH=#{directory}:$PATH #{kitchen_binstub} test"
          end

        ::Dir
          .chdir "integration/Shell Words" do
            sh "KITCHEN_LOG=debug PATH=#{directory}:$PATH #{kitchen_binstub} test"
          end
      end
    end
  end
end

task default: "tests:unit:run"
