class UserController < ApplicationController
  
  before_filter :authenticate_user!
  
  def profile
    @user = current_user
    if request.put?
      if @user.update_attributes(params[:user])
        flash[:notice] = "Your profile has been updated."
        redirect_to :root
      end
    end
  end
  
  def contact
    id = params[:id]
    @user = current_user
    @buddy = User.find(id)
    if request.put?
      Contact.send_contact(@user, @buddy, params[:message])
      flash[:notice] = "Buddy contact has been sent ... watch your email box."
      redirect_to :root
    end
  end
  
end
