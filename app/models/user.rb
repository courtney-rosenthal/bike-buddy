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
              :greater_than => BikeBuddy::Application.config.bike_buddy.geo_range.latitude.begin,
              :less_than => BikeBuddy::Application.config.bike_buddy.geo_range.latitude.end,
              :message => "invalid or outside service area"
            }
  validates :origination_longitude, :numericality => {
              :greater_than => BikeBuddy::Application.config.bike_buddy.geo_range.longitude.begin,
              :less_than => BikeBuddy::Application.config.bike_buddy.geo_range.longitude.end,
              :message => "invalid or outside service area"
            }
  validates :destination_address, :presence => true
  validates :destination_latitude, :numericality => {
              :greater_than => BikeBuddy::Application.config.bike_buddy.geo_range.latitude.begin,
              :less_than => BikeBuddy::Application.config.bike_buddy.geo_range.latitude.end,
              :message => "invalid or outside service area"
            }
  validates :destination_longitude, :numericality => {
              :greater_than => BikeBuddy::Application.config.bike_buddy.geo_range.longitude.begin,
              :less_than => BikeBuddy::Application.config.bike_buddy.geo_range.longitude.end,
              :message => "invalid or outside service area"
            }
  validates :schedule, :length => {:maximum => User.columns_hash["schedule"].limit}
  validates :user_note, :length => {:maximum => User.columns_hash["user_note"].limit}
            
  validate :validate_distance
  
  def commute_straight_line_distance
    BikeBuddy::Geo.distance(origination_latitude, origination_longitude, destination_latitude, destination_longitude)
  end
  
  def validate_distance
    d = commute_straight_line_distance
    if d < 0.5
      errors[:base] << "Commute distance is too short"
    elsif d > 30.0
      errors[:base] << "Commute distance is too long"
    end
  end

  after_initialize :set_defaults
  
  def set_defaults
    self.is_experienced = false if self.is_experienced.nil?
    self.is_enabled = true if self.is_enabled.nil?
    self.contact_opt_in = true if self.contact_opt_in.nil?
    self.origination_address ||= BikeBuddy::Application.config.bike_buddy.geo_center.address
    self.origination_latitude ||= BikeBuddy::Application.config.bike_buddy.geo_center.latitude
    self.origination_longitude ||= BikeBuddy::Application.config.bike_buddy.geo_center.longitude
    self.destination_address ||= BikeBuddy::Application.config.bike_buddy.geo_center.address
    self.destination_latitude ||= BikeBuddy::Application.config.bike_buddy.geo_center.latitude
    self.destination_longitude ||= BikeBuddy::Application.config.bike_buddy.geo_center.longitude
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
