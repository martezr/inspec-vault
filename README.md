# HashiCorp Vault - InSpec Profile

## Description

This [InSpec](https://github.com/chef/inspec) compliance profile checks security best practices for the HashiCorp Vault server

InSpec is an open-source run-time framework and rule language used to specify compliance, security, and policy requirements for testing any node in your infrastructure.

## Requirements

* at least [InSpec](http://inspec.io/) version 1.38.8
* [HashiCorp Vault](https://www.vaultproject.io/downloads.html)

## Resources

### `vault_command`

Use the `vault_command()` InSpec custom resource in your own InSpec profiles to test objects in your Vault server via the CLI (requires the `vault` cli available in your `PATH` where you run `inspec`). If the command stdout can be parsed as JSON (specify `-format=json` in your vault command), then any top-level JSON keys can be accessed as attributes of the resource.

See [`test/vault-command/`](test/vault-command/) for an example InSpec profile using the `vault_command()` custom resource from this profile as a dependency. Or, follow the example below.

#### Example

First, add this profile as a dependency in your profile's inspec.yml

```yaml
name: my-vault-profile
version: 0.1.0
depends:
- name: inspec-vault
  # see https://www.inspec.io/docs/reference/profiles/#git for available config
  git: https://github.com/martezr/inspec-vault
  branch:  master
```

Then add your controls in your profile's `controls/` directory using the `vault_command()` custom resource from this profile you now depend on.

```ruby
# VAULT_ADDR and VAULT_TOKEN env vars should first be exported
describe vault_command('status') do
  its('stdout') { should match(/^Sealed\s+false\s*$/) }
  its('stdout') { should match(/^Version\s+0\.11\.\d+\s*$/) }
  its('stdout') { should match(/^Cluster Name\s+vault-cluster-\w+\s*$/) }
  # json is the stdout parsed as JSON. if stdout could not be parsed as JSON, json is nil
  its('json') { should be_nil }
  its('stderr') { should cmp '' }
end

# If the output can be parsed as JSON, the top level keys of the JSON response are available
describe vault_command('status -format=json') do
  its('sealed') { should cmp false }
  its('version') { should match(/0\.11\.\d+/) }
  its('cluster_name') { should match(/vault-cluster-\w+/) }
  its('stderr') { should cmp '' }
end

# If VAULT_ADDR and VAULT_TOKEN env vars are not set, they can be specified in vault_command()
describe vault_command('secrets list -format=json', vault_addr: 'http://localhost:8200', vault_token: 'root-token') do
  its('secret/') { should include('type' => 'kv', 'options' => { 'version' => '2' }) }
  # json is the stdout parsed as JSON. if stdout could not be parsed as JSON, json is nil
  its('json') { should_not include('bad-secret-path/')}
  its('stderr') { should cmp '' }
end
```

Test out your profile

```shell
# navigate to your inspec profile
cd my-vault-profile

# specify vault address and token via env vars (or in the controls code shown above)
export VAULT_ADDR=http://localhost:8200 VAULT_TOKEN=root-token

# run a dev vault server in the background
vault server -dev "-dev-root-token-id=${VAULT_TOKEN}" &

# run your inspec profile!
inspec exec .

#  Vault Command: 'status'
#     ✔  stdout should match /^Sealed\s+false\s*$/
#     ✔  stdout should match /^Version\s+0\.11\.\d+\s*$/
#     ✔  stdout should match /^Cluster Name\s+vault-cluster-\w+\s*$/
#     ✔  stderr should cmp == ""
#  Vault Command: 'status -format=json'
#     ✔  sealed should cmp == false
#     ✔  version should match /0\.11\.\d+/
#     ✔  cluster_name should match /vault-cluster-\w+/
#     ✔  stderr should cmp == ""
#  Vault Command: 'secrets list -format=json'
#     ✔  secret/ should include {"type" => "kv", "options" => {"version" => "2"}}
#     ✔  stderr should cmp == ""

# after your tests you can kill the vault server you sent to the background
pkill vault
```

### Platform

- CentOS 7

## Attributes

We use a yml attribute file to steer the configuration, the following options are available:

  * `vault_user: vault`
    define trusted user to run the Vault service
  * `vault_service: vault`
    The name of the vault service
  * `vault_service_path: /etc/systemd/system/vault.service`
    The path on the system where the Vault service configuration file is located
  * `vault_dir: /opt/vault`
    The system path for the vault installation
  * `vault_user: vault`
    The system user account that the vault service runs as
  * `vault_tlscert: /opt/vault/ssl/server_cert.pem`
    Path to TLS certificate file
  * `vault_tlskey: /opt/vaul/ssl/server_key.pem`
    Path to TLS key file

## Usage

InSpec makes it easy to run your tests wherever you need. More options listed here: [InSpec cli](http://inspec.io/docs/reference/cli/)

```
# run profile locally
$ git clone https://github.com/martezr/inspec-vault
$ inspec exec inspec-vault

# run profile locally and directly from Github
$ inspec exec https://github.com/martezr/inspec-vault
```

## License, Author, and Contributors

* Author:: Martez Reed <martez.reed@greenreedtech.com>

#### Contributors

- Austin Heiman <atheimanksu@gmail.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
