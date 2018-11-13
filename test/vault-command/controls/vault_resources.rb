# VAULT_ADDR and VAULT_TOKEN env vars should first be exported
describe vault_command('status') do
  its('stdout') { should match /^Sealed\s+false\s*$/ }
  its('stdout') { should match /^Version\s+0\.11\.\d+\s*$/ }
  its('stdout') { should match /^Cluster Name\s+vault-cluster-\w+\s*$/ }
  its('stderr') { should cmp '' }
end

# If the output can be parsed as json, the top level keys of the response are available
describe vault_command('status -format=json') do
  its('sealed') { should cmp false }
  its('version') { should match /0\.11\.\d+/ }
  its('cluster_name') { should match /vault-cluster-\w+/ }
  its('stderr') { should cmp '' }
end

# If VAULT_ADDR and VAULT_TOKEN env vars are not set, they can be specified in vault_command()
describe vault_command('secrets list -format=json', vault_addr: 'http://localhost:8200', vault_token: 'root-token') do
  its('secret/') { should include('type' => 'kv', 'options' => { 'version' => '2' }) }
  its('stderr') { should cmp '' }
end
