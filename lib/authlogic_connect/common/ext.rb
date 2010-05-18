class String
  # normalizes an OpenID according to http://openid.net/specs/openid-authentication-2_0.html#normalization
  def normalize_identifier
    # clean up whitespace
    identifier = self.dup.strip

    # if an XRI has a prefix, strip it.
    identifier.gsub!(/xri:\/\//i, '')

    # dodge XRIs -- TODO: validate, don't just skip.
    unless ['=', '@', '+', '$', '!', '('].include?(identifier.at(0))
      # does it begin with http?  if not, add it.
      identifier = "http://#{identifier}" unless identifier =~ /^http/i

      # strip any fragments
      identifier.gsub!(/\#(.*)$/, '')

      begin
        uri = URI.parse(identifier)
        uri.scheme = uri.scheme.downcase  # URI should do this
        identifier = uri.normalize.to_s
      rescue URI::InvalidURIError
        raise InvalidOpenId.new("#{identifier} is not an OpenID identifier")
      end
    end

    return identifier
  end
end

class Hash
  def recursively_symbolize_keys!
    self.symbolize_keys!
    self.values.each do |v|
      if v.is_a? Hash
        v.recursively_symbolize_keys!
      elsif v.is_a? Array
        v.recursively_symbolize_keys!
      end
    end
    self
  end
end

class Array
  def recursively_symbolize_keys!
    self.each do |item|
      if item.is_a? Hash
        item.recursively_symbolize_keys!
      elsif item.is_a? Array
        item.recursively_symbolize_keys!
      end
    end
  end
end