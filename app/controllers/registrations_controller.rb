class RegistrationsController < Devise::RegistrationsController
  
  def build_resource(hash = nil)
    super(hash || params[resource_name] || User::INIT_DEFAULTS)
  end
  
end
