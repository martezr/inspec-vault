require "net/http"
require "uri"

# Custom resource based on the InSpec resource DSL
class VaultVersion < Inspec.resource(1)
  name 'vault_version'

  supports platform: 'unix'

  desc "
    Validate the version of HashiCorp Vault
  "

  example "
    describe vault_version do
      its('version') { should eq('v0.10.1') }
      its('sha') { should eq('756fdc4587350daf1c65b93647b2cc31a6f119cd') }
    end
  "

  def initialize
    cmd = inspec.command('vault version')
    @version_data = cmd.stdout if cmd.exit_status == 0
  end

  def version
    @version_data.split(' ')[1]
  end

  def sha
    sha_data = @version_data.split(' ')[2]
    sha_output = sha_data[2...-2]
  end

  def version_creep
    @version_data.split(' ')[1]
    uri = URI("https://releases.hashicorp.com/vault/")

    output = Net::HTTP.get(uri)
    print output
  end
end
