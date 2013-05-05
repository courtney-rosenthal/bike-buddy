module BikeBuddy
  
  # Geospatial support functions for Bike Buddy app.
  module Geo
  
    # value(degrees) * DEG_TO_RAD = value(radians)
    DEG_TO_RAD = Math::PI / 180.0
  
    # Earth mean radius, in miles.
    EARTH_R = 3963.0
    
    # Calculate distance in miles between two locations.
    #
    # Based on equitorial approximation formula at:
    # http://www.movable-type.co.uk/scripts/latlong.html  
    #
    def self.distance(lat1_deg, lng1_deg, lat2_deg, lng2_deg)
      lat1 = lat1_deg * DEG_TO_RAD
      lng1 = lng1_deg * DEG_TO_RAD
      lat2 = lat2_deg * DEG_TO_RAD
      lng2 = lng2_deg * DEG_TO_RAD
    
      x = (lng1-lng2) * Math.cos((lat2+lat1)/2);
      y = (lat1-lat2);
      Math.sqrt(x*x + y*y) * EARTH_R;
    end  
  
    
    # Return a range of degrees latitude,
    # centered on a given latitude, extending
    # a given number of miles in each direction.
    def self.latitude_range(lat, miles)
      delta = (miles/EARTH_R) / DEG_TO_RAD
      lat-delta .. lat+delta
    end
    
    # Return a range of degrees longitude,
    # centered on a given longitude, extending
    # a given number of miles in each direction.
    #
    # Latitude is required, because miles per
    # degree longitude varies as you move up
    # or down the sphere.
    def self.longitude_range(lat, lng, miles)
      r = EARTH_R * Math.cos(lat * DEG_TO_RAD)
      delta = (miles/r) / DEG_TO_RAD
      lng-delta .. lng+delta
    end

  end
end