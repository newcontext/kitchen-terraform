# ![Kitchen-Terraform Logo][kitchen-terraform-logo] Kitchen-Terraform

> Kitchen-Terraform enables verification of infrastructure systems provisioned with Terraform.

[![Gem version][gem-version-shield]][kitchen-terraform-gem]
[![Gem downloads version][gem-downloads-version-shield]][kitchen-terraform-gem]
[![Gem downloads total][gem-downloads-total-shield]][kitchen-terraform-gem]

[![Test workflow][test-workflow-shield]][test-workflow]
[![Code coverage][code-coverage-shield]][code-coverage]
[![Maintainability][maintainability-shield]][maintainability]
[![Technical debt][technical-debt-shield]][technical-debt]
[![Dependencies][hakiri-shield]][hakiri]

[![Gitter chat][gitter-shield]][gitter]

Kitchen-Terraform provides a set of [Kitchen][kitchen] plugins
which enable the use of Kitchen to converge a [Terraform][terraform]
configuration and verify the resulting infrastructure systems with
[InSpec][inspec] controls.

As Kitchen-Terraform integrates several distinctive technologies in a
nontrivial manner, reviewing the documentation of each of the
aforementioned products is strongly encouraged.

## Installation

### Terraform

Kitchen-Terraform integrates with the
[Terraform command-line interface][terraform-cli] to implement a Test
Kitchen workflow for Terraform modules.

Installation instructions can be found in the
[Terraform: Install Terraform][terraform-install] article.

Kitchen-Terraform supports versions of Terraform in the interval of
`>= 0.11.4, < 1.1.0`.

[tfenv] can be used to manage versions of Terraform on the system.

### Ruby

Kitchen-Terraform is written in [Ruby][ruby] which requires an
interpreter to be installed on the system.

Installation instructions can be found in the
[Ruby: Installing Ruby][ruby-installation] article.

Kitchen-Terraform aims to support all versions of Ruby that are in
["normal" or "security" maintenance][ruby-branches], which is currently
the interval of `>= 2.4, < 2.8`.

[rbenv] can be used to manage versions of Ruby on the system.

### Kitchen-Terraform Ruby Gem

Each version of Kitchen-Terraform is published as a
[Ruby gem][ruby-gems-what-is] to [RubyGems.org][kitchen-terraform-gem]
which makes them readily available for installation on a system.

#### Bundler

[Bundler][bundler] should be used to manage versions of
Kitchen-Terraform on the system. Using Bundler provides easily
reproducible Ruby gem installations that can be shared with other
systems.

First, create a `Gemfile` with contents like the following example. The
pessimistic pinning of the version is recommended to benefit from
the semantic versioning of the Ruby gem.

> Defining Kitchen-Terraform as a dependency for Bundler in a Gemfile

```ruby
source "https://rubygems.org/" do
  gem "kitchen-terraform", "~> 5.7"
end
```

Second, run the following command.

> Installing Kitchen-Terraform with Bundler

```sh
bundle install
```

The preceding command will create a `Gemfile.lock` comprising a list
of the resolved Ruby gem dependencies.

More information can be found in the
[Bundler: In Depth][bundler-in-depth] article.

#### RubyGems

RubyGems, the default Ruby package manager, can also be used to install
a version of Kitchen-Terraform by running a command like the following
example.

> Installing Kitchen-Terraform with RubyGems

```sh
gem install kitchen-terraform --version 6.0.0
```

This approach is not recommended as it requires more effort to install
the gem in a manner that is reproducible and free of dependency
conflicts.

More information can be found in the
[RubyGems: Installing Gems][rubygems-installing-gems] article.

#### Extra Dependencies

The RbNaCl gem may need to be [installed][rbnacl-installation] in order
to use Ed25519-type SSH keys to connect to systems with the SSH backend.
This gem implicitly depends on the system package libsodium, and its
presence when libsodium is not installed causes unexpected errors when
loading InSpec transport plugins like GCP, so it is not included by
default to reduce the burden on users whom do not require support for
Ed25519-type SSH keys.

## Usage

### Configuration

Kitchen-Terraform provides three Test Kitchen plugins which must be
configured in a
[Kitchen configuration file][kitchen-configuration-file] in
order to successfully test Terraform configuration.

The [Terraform driver][terraform-driver] manages the state of the
Terraform root module.

The [Terraform provisioner][terraform-provisioner] uses the Terraform
driver to apply changes to the Terraform state.

The [Terraform verifier][terraform-verifier] uses InSpec to verify the
Terraform state.

More information can be found in the
[Ruby gem documentation][ruby-gem-documentation].

### Caveats

The verifier does not currently utilize the standard `log_level` configuration setting.
To get debug output from the verifier use the environment variable:

```bash
KITCHEN_LOG=debug bundle exec kitchen verify
```

Versions of Terraform in the 0.11 series may cause `kitchen test` to
fail if the initial destroy targets an empty Terraform state. A
workaround for this problem is to use
`kitchen verify && kitchen destroy` instead of `kitchen test`. More
details about the problem are available in
[issue #271](issue-271).

### Tutorials and Examples

Several tutorials are available on the
[Kitchen-Terraform Tutorials][kitchen-terraform-tutorials] page.

The integration tests for Kitchen-Terraform can also be viewed as
examples of how it works. The
[integration test Kitchen configuration file][int-kitchen-config]
and the [integration test directory][test-directory] provide several
functional examples which exercise various features of
Kitchen-Terraform.

## Contributing

Kitchen-Terraform thrives on community contributions.

Information about contributing to Kitchen-Terraform can be found in the
[Contributing document][contributing-document].

## Changelog

Kitchen-Terraform adheres to semantic versioning and documents all
significant changes accordingly.

Information about changes to Kitchen-Terraform can be found in the
[Changelog][changelog].

## Maintainers

Kitchen-Terraform is maintained by [community contributors][contributors]
and Copado NCS LLC.

<img
  alt="Copado logo"
  height="25"
  src="https://raw.githubusercontent.com/newcontext-oss/kitchen-terraform/master/assets/copado_logo.png"
  width="25"> [copado.com][copado]

<img
  alt="Twitter logo"
  height="25"
  src="https://raw.githubusercontent.com/newcontext-oss/kitchen-terraform/master/assets/twitter_logo.png"
  width="25"> [@CopadoSolutions][copado-twitter]

<img
  alt="LinkedIn logo"
  height="23"
  src="https://raw.githubusercontent.com/newcontext-oss/kitchen-terraform/master/assets/linkedin_logo.png"
  width="25"> [Copado][copado-linkedin]

<img
  alt="GitHub logo"
  height="25"
  src="https://raw.githubusercontent.com/newcontext-oss/kitchen-terraform/master/assets/github_logo.png"
  width="25"> [@CopadoSolutions][copado-github]

<img
  alt="Email logo"
  height="16"
  src="https://raw.githubusercontent.com/newcontext-oss/kitchen-terraform/master/assets/email_logo.png"
  width="25"> kitchen-terraform@copado.com

<img
  alt="Email logo"
  height="16"
  src="https://raw.githubusercontent.com/newcontext-oss/kitchen-terraform/master/assets/email_logo.png"
  width="25"> ss-info@copado.com

## License

Kitchen-Terraform is distributed under the [Apache License][license].

<!-- Markdown links and image definitions -->

[appveyor-build-status-shield]: https://ci.appveyor.com/api/projects/status/8d7t014gij5grk5r/branch/master?svg=true
[appveyor-build-status]: https://ci.appveyor.com/project/aaron-lane/kitchen-terraform/branch/master
[bundler-getting-started]: https://bundler.io/#getting-started
[bundler-in-depth]: https://bundler.io/gemfile.html
[bundler]: https://bundler.io/index.html#getting-started
[changelog]: https://github.com/newcontext-oss/kitchen-terraform/blob/master/CHANGELOG.md
[code-coverage-shield]: https://img.shields.io/codeclimate/coverage/newcontext-oss/kitchen-terraform.svg
[code-coverage]: https://codeclimate.com/github/newcontext-oss/kitchen-terraform/
[contributing-document]: https://github.com/newcontext-oss/kitchen-terraform/blob/master/CONTRIBUTING.md
[contributors]: https://github.com/newcontext-oss/kitchen-terraform/graphs/contributors
[docker]: https://www.docker.com/
[docker-community-edition]: https://store.docker.com/editions/community/docker-ce-server-ubuntu
[docker-provider]: https://www.terraform.io/docs/providers/docker/index.html
[gem-downloads-total-shield]: https://img.shields.io/gem/dt/kitchen-terraform.svg
[gem-downloads-version-shield]: https://img.shields.io/gem/dtv/kitchen-terraform.svg
[gem-version-shield]: https://img.shields.io/gem/v/kitchen-terraform.svg
[gitter-shield]: https://img.shields.io/gitter/room/kitchen-terraform/Lobby.svg
[gitter]: https://gitter.im/kitchen-terraform/Lobby
[hakiri-shield]: https://hakiri.io/github/newcontext-oss/kitchen-terraform/master.svg
[hakiri]: https://hakiri.io/github/newcontext-oss/kitchen-terraform/
[inspec]: https://www.inspec.io/
[int-kitchen-config]: https://github.com/newcontext-oss/kitchen-terraform/blob/master/kitchen.yml
[issue-271]: https://github.com/newcontext-oss/kitchen-terraform/issues/271
[kitchen]: http://kitchen.ci/index.html
[kitchen-configuration-file]: https://docs.chef.io/config_yml_kitchen.html
[kitchen-terraform-gem]: https://rubygems.org/gems/kitchen-terraform
[kitchen-terraform-logo]: https://raw.githubusercontent.com/newcontext-oss/kitchen-terraform/master/assets/logo.png
[kitchen-terraform-tutorials]: https://newcontext-oss.github.io/kitchen-terraform/tutorials/
[license]: https://github.com/newcontext-oss/kitchen-terraform/blob/master/LICENSE
[maintainability-shield]: https://img.shields.io/codeclimate/maintainability-percentage/newcontext-oss/kitchen-terraform.svg
[maintainability]: https://codeclimate.com/github/newcontext-oss/kitchen-terraform/
[copado-github]: https://github.com/CopadoSolutions
[copado-linkedin]: https://www.linkedin.com/company/copado-solutions-s.l
[copado-twitter]: https://twitter.com/CopadoSolutions
[copado]: https://copado.com/
[rbenv]: https://github.com/rbenv/rbenv
[rbnacl-installation]: https://github.com/crypto-rb/rbnacl/tree/v4.0.2#installation
[ruby-branches]: https://www.ruby-lang.org/en/downloads/branches/
[ruby-gem-documentation]: http://www.rubydoc.info/github/newcontext-oss/kitchen-terraform/
[ruby-gems-what-is]: http://guides.rubygems.org/ruby-gems-what-is/index.html
[ruby-installation]: https://www.ruby-lang.org/en/documentation/installation/
[ruby]: https://www.ruby-lang.org/en/
[rubygems-installing-gems]: http://guides.rubygems.org/rubygems-basics/#rubygems-installing-gems
[technical-debt-shield]: https://img.shields.io/codeclimate/tech-debt/newcontext-oss/kitchen-terraform.svg
[technical-debt]: https://codeclimate.com/github/newcontext-oss/kitchen-terraform/
[terraform-cli]: https://www.terraform.io/docs/commands/index.html
[terraform-driver]: http://www.rubydoc.info/github/newcontext-oss/kitchen-terraform/Kitchen/Driver/Terraform
[terraform-install]: https://www.terraform.io/intro/getting-started/install.html
[terraform-provisioner]: http://www.rubydoc.info/github/newcontext-oss/kitchen-terraform/Kitchen/Provisioner/Terraform
[terraform-verifier]: http://www.rubydoc.info/github/newcontext-oss/kitchen-terraform/Kitchen/Verifier/Terraform
[terraform]: https://www.terraform.io/
[test-directory]: https://github.com/newcontext-oss/kitchen-terraform/tree/master/test
[test-workflow]: https://github.com/newcontext-oss/kitchen-terraform/actions/workflows/tests.yml
[test-workflow-shield]: https://github.com/newcontext-oss/kitchen-terraform/actions/workflows/tests.yml/badge.svg
[tfenv]: https://github.com/kamatama41/tfenv
[travis-build-status-shield]: https://img.shields.io/travis/com/newcontext-oss/kitchen-terraform.svg
[travis-build-status]: https://travis-ci.com/newcontext-oss/kitchen-terraform
