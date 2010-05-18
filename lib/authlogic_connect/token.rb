class Token < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :key, :secret
  
  def client
    self.class.client
  end
  
  def consumer
    self.class.consumer
  end
  
  def service_name
    self.class.service_name
  end
  
  def settings
    self.class.settings
  end
  
  def get(path)
    
  end
  
  class << self
    def service_name
      @service_name ||= self.to_s.underscore.scan(/^(.*?)(_token)?$/)[0][0].to_sym
    end
    
    def client
      raise "implement client in subclass"
    end
    
    def consumer
      raise "implement consumer in subclass"
    end
    
    def settings(site, hash = {})
      @settings = hash.merge(:site => site)
    end
    
    def config
      @settings ||= {}
    end
    
    protected
    
    def credentials
      @credentials ||= AuthlogicConnect.credentials(service_name)
    end
  end
  
end
