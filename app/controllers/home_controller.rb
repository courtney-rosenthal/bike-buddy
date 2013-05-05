class HomeController < ApplicationController

  def index
    @user = current_user
    @mapdata = User.mapdata(@user)
    
    @buddyMapOpts = if @user
      {
        :startLat => @user.origination_latitude,
        :startLng => @user.origination_longitude,
        :currentUser => @user.id,
        :data => @mapdata,
      }
    else
      {
        :startLat => BikeBuddy::Application.config.bike_buddy.geo_center.latitude,
        :startLng => BikeBuddy::Application.config.bike_buddy.geo_center.longitude,
        :currentUser => nil,
        :data => @mapdata,
      }
    end    
    
  end

end
