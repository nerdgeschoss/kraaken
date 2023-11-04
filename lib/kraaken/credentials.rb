# frozen_string_literal: true

class Kraaken::Credentials
  Credential = Struct.new(:username, :password)

  def credential(name)
    raise "Not implemented"
  end

  def password(name)
    credential(name).password
  end
end
