class OpenidToken < Token
  
  before_save :format_identifier
  
  def format_identifier
    self.key = self.key.to_s.normalize_identifier unless self.key.blank?
  end
  
end