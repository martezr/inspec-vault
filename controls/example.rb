# encoding: utf-8
# copyright: 2018, The Authors

describe vault_version do
  its('version') { should eq('v0.10.1') }
  its('sha') { should eq('756fdc4587350daf1c65b93647b2cc31a6f119cd') }
end

describe vault_audit_file do
  its('status') { should eq('enabled') }
  its('path') { should eq('/tmp/example-file.txt') }
end
