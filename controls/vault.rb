vault_service = attribute('vault_service', default: 'vault', description: 'The name of the vault service')
vault_user = attribute('vault_user', default: 'vault', description: 'The system user account that the vault service runs as')

describe vault_version do
  its('version') { should eq('v0.10.1') }
  its('sha') { should eq('756fdc4587350daf1c65b93647b2cc31a6f119cd') }
end

describe vault_audit_file do
  its('status') { should eq('enabled') }
  its('path') { should eq('/tmp/example-file.txt') }
end

describe service(vault_service) do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end
