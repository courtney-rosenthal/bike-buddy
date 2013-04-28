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
        :startLat => User::DEFAULT_LATITUDE,
        :startLng => User::DEFAULT_LONGITUDE,
        :currentUser => nil,
        :data => @mapdata,
      }
    end    
    
  end

end
