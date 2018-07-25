# HashiCorp Vault - InSpec Profile

## Description

This [InSpec](https://github.com/chef/inspec) compliance profile checks security best practices for the HashiCorp Vault server

InSpec is an open-source run-time framework and rule language used to specify compliance, security, and policy requirements for testing any node in your infrastructure.

## Requirements

* at least [InSpec](http://inspec.io/) version 1.38.8
* HashiCorp Vault

### Platform

- CentOS 7

## Attributes

We use a yml attribute file to steer the configuration, the following options are available:

  * `vault_user: vault`
    define trusted user to run the Vault service

## Usage

InSpec makes it easy to run your tests wherever you need. More options listed here: [InSpec cli](http://inspec.io/docs/reference/cli/)

```
# run profile locally
$ git clone https://github.com/martezr/inspec-vault
$ inspec exec inspec-vault

# run profile locally and directly from Github
$ inspec exec https://github.com/martezr/inspec-vault
```

## License and Author

* Author:: Martez Reed <martez.reed@greenreedtech.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
