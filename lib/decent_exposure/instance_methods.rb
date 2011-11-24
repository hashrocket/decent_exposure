module DecentExposure
  
  module InstanceMethods
    
    def over_expose(name, val)
      @_resources = {}
      @_resources[name] = val
    end
      
  end
  
end