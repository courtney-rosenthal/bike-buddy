require 'ostruct'
require 'bike_buddy/geo'

BikeBuddy::Application.configure do
  config.bike_buddy = OpenStruct.new

  # Center point of the map.
  #
  # The map on the home page (for a non-logged-in user)
  # is centered on this location.
  #
  # This is also the default starting point for the
  # origination/destination place pickers when creating
  # a new profile.
  #
  config.bike_buddy.geo_center = OpenStruct.new({
    :latitude => 30.261214,
    :longitude => -97.736375,
    :address => "East Cesar Chavez Street, Austin, TX 78702, USA",
  })
  
  # The service area is a square, extending this
  # distance in each direction.
  #
  # All origination and destination points must
  # be within this region.
  #
  config.bike_buddy.service_range = 20.0 # miles  

  # Calculate range of service area from above settings.
  #
  # You shouldn't have to adjust this.
  #
  config.bike_buddy.geo_range = OpenStruct.new({
    :latitude => BikeBuddy::Geo.latitude_range(
      config.bike_buddy.geo_center.latitude,
      config.bike_buddy.service_range),
    :longitude => BikeBuddy::Geo.longitude_range(
      config.bike_buddy.geo_center.latitude,
      config.bike_buddy.geo_center.longitude,
      config.bike_buddy.service_range)
  })
end

