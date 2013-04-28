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
    
  # default center location for maps
  DEFAULT_LATITUDE = 30.261214068166684
  DEFAULT_LONGITUDE = -97.73637580871582
  DEFAULT_ADDRESS = "East Cesar Chavez Street, Austin, TX 78702, USA"
    
  INIT_DEFAULTS = {
    :is_experienced => false,
    :is_enabled => true,
    :contact_opt_in => false,
    :origination_address => DEFAULT_ADDRESS,
    :origination_latitude => DEFAULT_LATITUDE,
    :origination_longitude => DEFAULT_LONGITUDE,
    :destination_address => DEFAULT_ADDRESS,
    :destination_latitude => DEFAULT_LATITUDE,
    :destination_longitude => DEFAULT_LONGITUDE,
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
  
  def origination_formatted
    self.class.cleanup_address(origination_address)
  end
  
  def destination_formatted
    self.class.cleanup_address(destination_address)
  end
  
  def mapdata(current_user = nil)      
    u = {
      # data elements to display to everybody ... including unregistered users
      :name => display_name,
      :isMe => false,
      :commuterType => commuter_type,
      :origination => {
        :latitude => origination_latitude,
        :longitude => origination_longitude,
      },
      :destination => {
        :latitude => destination_latitude,
        :longitude => destination_longitude,
      },
    }.merge(current_user ? {
      # data elements to display only to logged in users
      :isMe => (current_user && current_user.id == id),
      :origination => {
        :latitude => origination_latitude,
        :longitude => origination_longitude,
        :address => origination_formatted,
      },
      :destination => {
        :address => destination_formatted,
        :latitude => destination_latitude,
        :longitude => destination_longitude,
      },
      :schedule => schedule,
      :note => user_note,
      :contactURL => Rails.application.routes.url_helpers.user_contact_path(self),
    } : {})  
  end
  
  def self.mapdata(current_user = nil)
    self.where(:is_enabled => true).map {|u| u.mapdata(current_user)}
  end  
    
end
