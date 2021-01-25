---
title: Provisioner
---

# Kitchen-Terraform Provisioner

The provisioner applies changes to the Terraform state based on the
configuration of the root module.
    
## Commands

The following command-line actions are provided by the provisioner:

* converge

### converge

A Kitchen instance is converged through the following steps:

* selecting the test Terraform workspace
* updating the Terraform dependency modules
* validating the Terraform root module
* applying the Terraform state changes
* retrieving the Terraform output

*Example*:

~~~
$ kitchen help converge
$ kitchen converge default-ubuntu
~~~
      
#### Selecting the Test Terraform Workspace

The provisioner selects the workspace by running a command like the 
following example:

~~~
terraform workspace select <name>
~~~

#### Updating the Terraform Dependency Modules

The provisioner updates the dependency modules by running a command 
like the following example:

~~~
terraform get -update <directory>
~~~

#### Validating the Terraform Root Module

The provisioner validates the root module by running a command like the 
following example, where the options are controlled by configuration 
attributes of the [driver](./driver.html):

~~~
terraform validate \
  [-no-color] \
  [-var=<variables.first>...] \
  [-var-file=<variable_files.first>...] \
  <directory>
~~~

#### Applying the Terraform State Changes

The provisioner applies the state changes by running a command like the 
following example, where the options are controlled by configuration 
attributes of the [driver](./driver.html):

~~~
terraform apply \
  -auto-approve=true \
  -input=false \
  -refresh=true \
  -lock-timeout=<lock_timeout>s \
  -lock=<lock> \
  -parallelism=<parallelism> \
  [-no-color] \
  [-var-file=<variable_files.first>...] \
  [-var=<variables.first>...] \
  <directory>
~~~

#### Retrieving the Terraform Output

The provisioner retrieves the outputs by running a command like the 
following example:

~~~
terraform output -json
~~~

## Configuration

Within the
[Kitchen configuration file](http://kitchen.ci/docs/getting-started/kitchen-yml), 
the `provisioner` mapping must be declared along with the plugin name:

~~~
provisioner:
  name: terraform
~~~
{: .language-yaml}

### Attributes

The provisioner has no configuration attributes, but rather relies on 
the attributes of the [driver](./driver.html).
