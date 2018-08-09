require 'digest/sha1'
# @summary
#   Hash a string 
#
Puppet::Functions.create_function(:'wordpress::password_hash') do
  # @param password
  #   Plain text password.
  #
  # @return the password hash from the clear text password.
  #
  dispatch :password do
    required_param 'String', :password
    return_type 'String'
  end

  def password(password)
    return '' if password.empty?
    Digest::SHA1.hexdigest(Digest::SHA512.digest(password))
  end
end
