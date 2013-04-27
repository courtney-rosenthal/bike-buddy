class HomeController < ApplicationController

  def index
    @user = current_user
    @mapdata = User.mapdata
  end

end
