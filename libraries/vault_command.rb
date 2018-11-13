require 'json'

class VaultCommand < Inspec.resource(1)
  name 'vault_command'
  desc 'Run Vault commands via InSpec'
  example <<~EOX
    # VAULT_ADDR and VAULT_TOKEN env vars should first be exported
    describe vault_command('status') do
      its('stdout') { should match(/^Sealed\s+false\s*$/) }
      its('stdout') { should match(/^Version\s+0\.11\.\d+\s*$/) }
      its('stdout') { should match(/^Cluster Name\s+vault-cluster-\w+\s*$/) }
      # response is the stdout parsed as JSON. if stdout could not be parsed as JSON, response is nil
      its('response') { should be_nil }
      its('stderr') { should cmp '' }
    end

    # If the output can be parsed as json, the top level keys of the response are available
    describe vault_command('status -format=json') do
      its('sealed') { should cmp false }
      its('version') { should match(/0\.11\.\d+/) }
      its('cluster_name') { should match(/vault-cluster-\w+/) }
      its('stderr') { should cmp '' }
    end

    # If VAULT_ADDR and VAULT_TOKEN env vars are not set, they can be specified in vault_command()
    describe vault_command('secrets list -format=json', vault_addr: 'http://localhost:8200', vault_token: 'root-token') do
      its('secret/') { should include('type' => 'kv', 'options' => { 'version' => '2' }) }
      # response is the stdout parsed as JSON. if stdout could not be parsed as JSON, response is nil
      its('response') { should_not include('bad-secret-path/')}
      its('stderr') { should cmp '' }
    end
  EOX

  attr_reader :command, :safe_command, :response, :result

  def initialize(cmd, vault_addr: nil, vault_token: nil)
    vault_addr ||= ENV['VAULT_ADDR'] || raise('Error: No Vault address found!')
    vault_token ||= ENV['VAULT_TOKEN'] || raise('Error: No Vault token found!')
    @safe_command = cmd
    @command = "VAULT_ADDR=#{vault_addr} VAULT_TOKEN=#{vault_token} vault #{cmd}"

    @result = inspec.backend.run_command(command)
    begin
      @response = JSON.parse(@result.stdout)
    rescue JSON::ParserError
      # Silently catch non-json output
    end
  end

  # Expose all response keys
  def method_missing(name)
    if @response.is_a? Hash
      if @response.key?(name.to_s)
        @response[name.to_s]
      else
        raise(
          NoMethodError,
          "undefined method '#{name}' for #{self} and not found in Vault CLI JSON response keys \
          #{@response.keys}"
        )
      end
    else
      super
    end
  end

  def stdout
    result.stdout
  end

  def stderr
    result.stderr
  end

  def exit_status
    result.exit_status.to_i
  end

  def to_s
    "Vault Command: '#{@safe_command}'"
  end
end
