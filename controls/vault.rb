# encoding: utf-8
# frozen_string_literal: true

# Copyright 2018, Martez Reed
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
#
# author: Martez Reed

title 'Vault Secure Configuration'

vault_service = attribute(
  'vault_service',
  default: 'vault',
  description: 'The name of the vault service'
)

vault_dir = attribute(
  'vault_dir',
  default: '/opt/vault',
  description: 'The system path for the vault installation'
)

vault_user = attribute(
  'vault_user',
  default: 'vault',
  description: 'The system user account that the vault service runs as'
)

# check if vault exists
only_if do
  command('vault').exist?
end

control 'vault-1.1' do
  impact 1.0
  title 'Ensure Vault is upgrade frequently'

  describe vault_version do
    its('version') { should cmp >= 'v0.10.1' }
  end
end

control 'vault-1.2' do
  impact 1.0
  title 'Secure Vault configuration files'

  describe directory(vault_dir) do
    its('owner') { should eq vault_user }
    it { should_not be_readable.by('others') }
    it { should_not be_writable.by('others') }
    it { should_not be_executable.by('others') }
  end
end

describe vault_audit_file do
  its('status') { should eq('enabled') }
  its('path') { should eq('/tmp/example-file.txt') }
end

describe directory(vault_dir) do
  its('owner') { should eq vault_user }
  it { should_not be_readable.by('others') }
  it { should_not be_writable.by('others') }
  it { should_not be_executable.by('others') }
end

describe service(vault_service) do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

describe auditd do
  its(:lines) { should include('-w /opt/vault/config -p rwxa -k vault') }
end
