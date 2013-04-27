class UserMailer < ActionMailer::Base
  default :from => "no-reply"
  
  def contact(initiating_user, receiving_user, message = nil)
    @initiating_user = initiating_user
    @receiving_user = receiving_user
    @message = message
    mail(:to => [@initiating_user.email_header, @receiving_user.email_header],
      :from => @initiating_user.email_header,
      :subject => "Bike Buddy contact request")
  end
  
end
