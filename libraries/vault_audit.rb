require 'json'

# Custom resource based on the InSpec resource DSL
class VaultAuditFile < Inspec.resource(1)
  name 'vault_audit_file'

  supports platform: 'unix'

  desc "
    Validate the version of HashiCorp Vault
  "

  example "
    describe vault_audit_file do
      its('status') { should eq('enabled') }
    end
  "

  def initialize
    cmd = inspec.command('vault audit list -format json -tls-skip-verify')
    @audit_data = cmd.stdout if cmd.exit_status?
  end

  def status
    if @audit_data == "No audit devices are enabled.\n"
      return 'disabled'
    elsif
      audit_type_data = JSON.parse(@audit_data)
      if audit_type_data.include? "file"
        print "file type"
      end
      return 'enabled'
    else
      return 'disabled'
    end
  end

  def path
    json_output = JSON.parse(@audit_data)
    file_path = json_output['file/']['Options']['file_path']
  end
end
