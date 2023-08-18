class Configuration
  attr_accessor :base_controller

  def base_controller_class
    self.base_controller || 'Api::ResourceController'
  end
end
