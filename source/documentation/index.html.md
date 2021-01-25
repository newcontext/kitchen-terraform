---
title: Documentation
---

# Kitchen-Terraform Documentation

Kitchen-Terraform provides three Kitchen plugins which must be
configured in a
[Kitchen configuration file][kitchen-configuration-file] in
order to test Terraform modules using the Kitchen executable.

The [Terraform driver](./driver.html) manages the state of the
Terraform root module.

The [Terraform provisioner](./provisioner.html) uses the Terraform
driver to apply changes to the Terraform state.

The [Terraform verifier](./verifier.html) uses InSpec to verify the
Terraform state.

[kitchen-configuration-file]: https://docs.chef.io/config_yml_kitchen.html