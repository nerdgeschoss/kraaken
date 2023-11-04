class Kraaken::Credentials::OnePassword < Kraaken::Credentials
  def credential(name)
    username = retrieve(name, "username")
    password = retrieve(name)
    Credential.new(username:, password:)
  end

  def password(name)
    retrieve name
  end

  private

  def retrieve(name, field = "password")
    stdout_str, stderr_str, exit_code = Open3.capture3("op read 'op://server/#{name}/#{field}'")
    raise StandardError.new(stderr_str) unless exit_code.success?
    stdout_str.strip.presence
  end
end
