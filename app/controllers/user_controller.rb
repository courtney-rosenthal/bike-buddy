class UserController < ApplicationController
  
  before_filter :authenticate_user!
  
  def profile
    @user = current_user
    if request.put?
      if @user.update_attributes(params[:user])
        flash[:notice] = "Your profile has been updated."
      else
        flash[:alert] = "No changes made. Please correct the problem and try again."
      end
    end
  end
  
end
