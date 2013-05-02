class User < ActiveRecord::Base
  
  # Include default devise modules. Others available are:
  #   :token_authenticatable, :confirmable,
  #   :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  attr_accessible :email, :password, :password_confirmation, :remember_me,
    :name, :is_enabled, :is_experienced, :phone, :contact_opt_in,
    :origination_address, :origination_latitude, :origination_longitude,
    :destination_address, :destination_latitude, :destination_longitude,
    :schedule, :user_note    
 
  
  
  validates :name, :length => {:in => 6 .. User.columns_hash["name"].limit}
  validates :is_enabled, :inclusion => {:in => [true, false]}
  validates :is_experienced, :inclusion => {:in => [true, false]}
  validates :phone, :length => {:maximum => User.columns_hash["phone"].limit}
  validates :contact_opt_in, :inclusion => {:in => [true, false]}
  validates :origination_address, :presence => true
  validates :origination_latitude, :numericality => {
              :greater_than => 29.96,
              :less_than => 30.55,
              :message => "invalid or outside service area"
            }
  validates :origination_longitude, :numericality => {
              :greater_than =>  -97.89,
              :less_than =>  -97.41,
              :message => "invalid or outside service area"
            }
  validates :destination_address, :presence => true
  validates :destination_latitude, :numericality => {
              :greater_than => 29.96,
              :less_than => 30.55,
              :message => "invalid or outside service area"
            }
  validates :destination_longitude, :numericality => {
              :greater_than =>  -97.89,
              :less_than =>  -97.41,
              :message => "invalid or outside service area"
            }
  validates :schedule, :length => {:maximum => User.columns_hash["schedule"].limit}
  validates :user_note, :length => {:maximum => User.columns_hash["user_note"].limit}
            
  validate :validate_distance
  
  def validate_distance
    d = crows_distance
    if d < 0.5
      errors[:base] << "Commute distance is too short"
    elsif d > 30.0
      errors[:base] << "Commute distance is too long"
    end
  end

  # default center location for maps
  DEFAULT_LATITUDE = 30.261214068166684
  DEFAULT_LONGITUDE = -97.73637580871582
  DEFAULT_ADDRESS = "East Cesar Chavez Street, Austin, TX 78702, USA"
  
  after_initialize :set_defaults
  
  def set_defaults
    self.is_experienced = false if self.is_experienced.nil?
    self.is_enabled = true if self.is_enabled.nil?
    self.contact_opt_in = true if self.contact_opt_in.nil?
    self.origination_address ||= DEFAULT_ADDRESS
    self.origination_latitude ||= DEFAULT_LATITUDE
    self.origination_longitude ||= DEFAULT_LONGITUDE
    self.destination_address ||= DEFAULT_ADDRESS
    self.destination_latitude ||= DEFAULT_LATITUDE
    self.destination_longitude ||= DEFAULT_LONGITUDE
  end
  
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
  
  DEG_TO_RAD = Math::PI / 180.0

  # Earth mean radius, in miles.
  EARTH_R = 3963.0
  
  #
  # Calculate distance from current location to another location.
  #
  # [loc]
  #   A FindIt::Location instance, to measure the distance to.
  #
  # Returns the calculated distance, in miles.
  #
  # Based on equitorial approximation formula at:
  # http://www.movable-type.co.uk/scripts/latlong.html  
  #
  def crows_distance
    lng1 = destination_longitude * DEG_TO_RAD
    lat1 = destination_latitude * DEG_TO_RAD
    lng2 = origination_longitude * DEG_TO_RAD
    lat2 = origination_latitude * DEG_TO_RAD
  
    x = (lng1-lng2) * Math.cos((lat2+lat1)/2);
    y = (lat1-lat2);
    Math.sqrt(x*x + y*y) * EARTH_R;
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
    self.where(:is_enabled => true).where("confirmed_at IS NOT NULL").map {|u| u.mapdata(current_user)}
  end  
    
end
