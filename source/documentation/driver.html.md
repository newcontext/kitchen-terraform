---
title: Driver
---

# Kitchen-Terraform Driver

The driver is the bridge between Kitchen and Terraform. It manages the
[state](https://www.terraform.io/docs/state/index.html) of the Terraform
root module by shelling out and running Terraform commands.

## Commands

The following command-line commands are provided by the driver:

* create
* destroy

### create

A Kitchen instance is created through the following steps:

* initializing the Terraform working directory
* creating or selecting the test Terraform workspace

*Example*:

~~~
$ kitchen help create
$ kitchen create default-ubuntu
~~~

#### Initializing the Terraform Working Directory

The driver initializes the working directory by running a command like 
the following example, where the options are controlled by 
configuration attributes:

~~~
terraform init \
  -backend=true \
  -force-copy \
  -get-plugins=true \
  -get=true \
  -input=false \
  -verify-plugins=true \
  -lock=<lock> \
  -lock-timeout=<lock_timeout>s \
  [-no-color] \
  [-upgrade] \
  [-backend-config=<backend_configurations[0]> ...] \
  [-plugin-dir=<plugin_directory>] \
  <root_module_directory>
~~~

#### Creating or Selecting the Test Terraform Workspace

The driver creates or selects the workspace by running a command like the 
following example:

~~~
terraform workspace new <name> || terraform workspace select <name>
~~~

### destroy

A Kitchen instance is destroyed through the following steps:

* initializing the Terraform working directory
* selecting or creating the test Terraform workspace
* destroying the Terraform state
* selecting the default Terraform workspace
* deleting the test Terraform workspace

*Example*:

~~~
$ kitchen help destroy
$ kitchen destroy default-ubuntu
~~~
      
#### Initializing the Terraform Working Directory

The driver initializes the working directory by running a command like 
the following example, where the options are controlled by 
configuration attributes:

~~~
terraform init \
  -backend=true \
  -force-copy \
  -get-plugins=true \
  -get=true \
  -input=false \
  -verify-plugins=true \
  -lock-timeout=<lock_timeout>s \
  -lock=<lock> \
  [-backend-config=<backend_configurations[0]> ...] \
  [-no-color] \
  [-plugin-dir=<plugin_directory>] \
  [-upgrade] \
  <root_module_directory>
~~~

#### Selecting or Creating the Test Terraform Workspace

The driver selects or creates the workspace by running a command like the 
following example:

~~~
terraform workspace select <name> || terraform workspace new <name>
~~~

#### Destroying the Terraform State

The driver destroys the state by running a command like the following
example, where the options are controlled by configuration
attributes:

~~~
terraform destroy \
  -auto-approve \
  -input=false \
  -refresh=true \
  -lock-timeout=<lock_timeout>s \
  -lock=<lock> \
  -parallelism=<parallelism> \
  [-no-color] \
  [-var-file=<variable_files.first>...] \
  [-var=<variables.first>...] \
  <root_module_directory>
~~~

#### Selecting the Default Terraform Workspace

The driver selects the workspace by running a command like the 
following example:

~~~
terraform workspace select default
~~~

#### Deleting the Test Terraform Workspace

The driver deletes the workspace by running a command like the following
example:

~~~
terraform workspace delete <name>
~~~

## Configuration

Within the
[Kitchen configuration file](http://kitchen.ci/docs/getting-started/kitchen-yml), 
the `driver` mapping must be declared along with the plugin name:

~~~
driver:
  name: terraform
~~~
{: .language-yaml}

### Attributes

The configuration attributes of the driver control the behaviour of the 
Terraform commands that are run.

### backend_configurations

This attribute comprises
[Terraform backend configuration](https://www.terraform.io/docs/backends/config.html)
arguments to complete a
[partial backend configuration](https://www.terraform.io/docs/backends/config.html#partial-configuration).

*YAML Type*: [Mapping of scalars to scalars](http://www.yaml.org/spec/1.2/spec.html#id2760142)

*Required*: False

*Default*: `{}`

*Example*:

~~~
driver:
  name: terraform
  backend_configurations:
    address: demo.consul.io
    path: example_app/terraform_state
~~~
{: .language-yaml}

### client

This attribute contains the pathname of the
[Terraform client](https://www.terraform.io/docs/commands/index.html) to
be used by Kitchen-Terraform.

The pathname of any executable file which implements the interfaces of
the following Terraform client commands may be specified:

* apply
* destroy
* get
* init
* validate
* workspace

[Terragrunt](https://terragrunt.gruntwork.io/) is an example of a
compatible Terraform client that could be used.

*YAML Type*: [Scalar](http://www.yaml.org/spec/1.2/spec.html#id2760844)

*Required*: False

*Default*: `terraform`

*Caveat*: If the value is not an absolute pathname or a relative
pathname then the driver will attempt to find the value in the
directories of the
[PATH](https://en.wikipedia.org/wiki/PATH_(variable)).

*Example*:

~~~
driver:
  name: terraform
  client: /usr/local/bin/terraform
~~~
{: .language-yaml}

### color

This attribute toggles colored output from shell-out commands invoked by
the driver.
      
*YAML Type*: [Boolean](http://www.yaml.org/spec/1.2/spec.html#id2803629)

*Required*: False

*Default*: If a
[terminal emulator](https://en.wikipedia.org/wiki/Terminal_emulator) is
associated with the Kitchen process then `true`; else `false`.

*Caveat*: This attribute does not toggle colored output from Kitchen
itself; that requires the use of the `--color` and `--no-color`
command-line flags.

*Example*:

~~~
driver:
  name: terraform
  color: false
~~~
{: .language-bash}

### command_timeout

This attribute controls the number of seconds that the plugin will wait
for Terraform commands to finish running.

*YAML Type*: [Integer](http://www.yaml.org/spec/1.2/spec.html#id2803828)

*Required*: False

*Default*: `600`

*Example*: 

~~~
driver:
  name: terraform
  command_timeout: 1200
~~~
{: .language-yaml}

### lock

This attribute toggles
[locking](https://www.terraform.io/docs/state/locking.html) of the
Terraform state file.
      
*YAML Type*: [Boolean](http://www.yaml.org/spec/1.2/spec.html#id2803629)

*Required*: False

*Default*: `true`

*Example*: 

~~~
driver:
  name: terraform
  lock: false
~~~
{: .language-yaml}

### lock_timeout

This attribute controls the number of seconds that Terraform will wait
for a lock on the state to be obtained during operations related to state.

*YAML Type*: [Integer](http://www.yaml.org/spec/1.2/spec.html#id2803828)

*Required*: False

*Default*: `0`

*Example*: 

~~~
driver:
  name: terraform
  lock_timeout: 10
~~~
{: .language-yaml}

### parallelism

This attribute controls the number of concurrent operations to use while
Terraform
[walks the resource graph](https://www.terraform.io/docs/internals/graph.html#walking-the-graph).

*YAML Type*: [Integer](http://www.yaml.org/spec/1.2/spec.html#id2803828)

*Required*: False

*Default*: +10+

*Example*:

~~~
driver:
  name: terraform
  parallelism: 50
~~~
{: .language-yaml}

### plugin_directory

This attribute contains the path to the directory which contains
[customized Terraform provider plugins](https://www.terraform.io/docs/commands/init.html#plugin-installation)
to install in place of the official Terraform provider plugins.

*YAML Type*: [Scalar](http://www.yaml.org/spec/1.2/spec.html#id2760844)

*Required*: False

*Default*: There is no default value because any value will disable the normal 
Terraform plugin retrieval process.

*Example*:

~~~
driver:
  name: terraform
  plugin_directory: /path/to/terraform/plugins
~~~
{: .language-yaml}

### root_module_directory

This attribute contains the path to the directory which contains the
root Terraform module to be tested.
      
*YAML Type*: [Scalar](http://www.yaml.org/spec/1.2/spec.html#id2760844)

*Required*: False

*Default*: The
[working directory](https://en.wikipedia.org/wiki/Working_directory) of
the Kitchen process.

*Example*:

~~~
driver:
  name: terraform
  root_module_directory: /path/to/terraform/root/module/directory
~~~
{: .language-yaml}

### variable_files

This attribute comprises paths to
[Terraform variable files](https://www.terraform.io/docs/configuration/variables.html#variable-files)
which will be sourced by Terraform.

*YAML Type*: [Sequence of scalars](http://www.yaml.org/spec/1.2/spec.html#id2760118)

*Required*: False

*Example*:

~~~
driver:
  name: terraform
  variable_files:
    - /path/to/first/variable/file
    - /path/to/second/variable/file
~~~
{: .language-yaml}

### variables

This attribute comprises
[Terraform variables](https://www.terraform.io/docs/configuration/variables.html)
which will be input to Terraform.
      
*YAML Type*: [Mapping of scalars to scalars](http://www.yaml.org/spec/1.2/spec.html#id2760142)

*Required*: False

*Example*:

~~~
driver:
  name: terraform
  variables:
    image: image-1234
    zone: zone-5
~~~
{: .language-yaml}

### verify_version

This attribute toggles strict or permissive verification of support for
the version of the Terraform client specified by the `client` attribute.

*YAML Type*: [Boolean](http://www.yaml.org/spec/1.2/spec.html#id2803629)

*Required*: False

*Default*: `true`

*Example*:

~~~
driver:
  name: terraform
  verify_version: false
~~~
{: .language-yaml}
