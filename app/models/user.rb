class User < ActiveRecord::Base
  
  # Include default devise modules. Others available are:
  #   :token_authenticatable, :confirmable,
  #   :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  # TODO validations
  attr_accessible :email, :password, :password_confirmation, :remember_me
  
  attr_accessible :name, :is_enabled, :is_experienced, :phone, :contact_opt_in,
    :origination_address, :origination_latitude, :origination_longitude,
    :destination_address, :destination_latitude, :destination_longitude,
    :schedule, :user_note
    
  INIT_DEFAULTS = {
    :is_experienced => false,
    :is_enabled => true,
    :contact_opt_in => false,
    :origination_address => "East Cesar Chavez Street, Austin, TX 78702, USA",
    :origination_latitude => 30.261214068166684,
    :origination_longitude => -97.73637580871582,
    :destination_address => "East Cesar Chavez Street, Austin, TX 78702, USA",
    :destination_latitude => 30.261214068166684,
    :destination_longitude => -97.73637580871582,
  }.freeze
  
  def email_header
    "#{name} <#{email}>"
  end
  
  def display_name
    name.sub(/\s+(.).*/, ' \1.')
  end
  
  def commuter_type
    is_experienced ? "Experienced" : "New"
  end
  
  def self.cleanup_address(s)
    s.gsub(/\s+/, ' ').gsub(/[, ]+(tx|texas|usa)\b/i, '')
  end
  
  def self.mapdata
    self.where(:is_enabled => true).map do |u|
      {
        :id => u.id,
        :name => u.display_name,
        :commuter_type => u.commuter_type,
        :origination => {
          :address => cleanup_address(u.origination_address),
          :latitude => u.origination_latitude,
          :longitude => u.origination_longitude,
        },
        :destination => {
          :address => cleanup_address(u.destination_address),
          :latitude => u.destination_latitude,
          :longitude => u.destination_longitude,
        },
        :schedule => u.schedule,
        :note => u.user_note,
      }
    end
  end
  
    
end
