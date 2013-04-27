class User < ActiveRecord::Base
  
  # Include default devise modules. Others available are:
  #   :token_authenticatable, :confirmable,
  #   :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  # TODO validations
  attr_accessible :email, :password, :password_confirmation, :remember_me
  
  attr_accessible :display_name, :is_experienced, :display_enabled, :phone, :contact_opt_in,
    :origination_address, :origination_latitude, :origination_longitude,
    :destination_address, :destination_latitude, :destination_longitude,
    :work_schedule, :user_notes
    
  INIT_DEFAULTS = {
    :is_experienced => false,
    :display_enabled => true,
    :contact_opt_in => false,
    :origination_address => "East Cesar Chavez Street, Austin, TX 78702, USA",
    :origination_latitude => 30.261214068166684,
    :origination_longitude => -97.73637580871582,
    :destination_address => "East Cesar Chavez Street, Austin, TX 78702, USA",
    :destination_latitude => 30.261214068166684,
    :destination_longitude => -97.73637580871582,
  }.freeze
  
  def email_header
    "#{display_name} <#{email}>"
  end
  
    
end
