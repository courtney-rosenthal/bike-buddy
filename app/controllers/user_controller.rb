class UserController < ApplicationController
  
  before_filter :authenticate_user!
  
  def profile
    @user = current_user
    require "pp" ; pp params
    if request.put?
      if @user.update_attributes(params[:user])
        flash[:notice] = "Your profile has been updated."
      else
        flash[:alert] = "No changes made. Please correct the problem and try again."
      end
    end
  end
  
  def contact
    id = params[:id]
    @user = current_user
    @buddy = User.find(id)
    if request.put?
      UserMailer.contact(@user, @buddy, params[:contact_note]).deliver
      flash[:notice] = "Buddy contact has been sent ... watch your email box."
      redirect_to :root
    end
  end
  
end
