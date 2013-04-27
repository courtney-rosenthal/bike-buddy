class User::RegistrationController < Devise::RegistrationsController
  
  def build_resource(hash = nil)
    super(User::INIT_DEFAULTS)
  end
  
end
