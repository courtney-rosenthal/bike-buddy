class Contact < ActiveRecord::Base
  belongs_to :initiator, :class_name => "User"
  belongs_to :recipient, :class_name => "User"
  validates :initiator, :recipient, :presence => true
  

  def self.send_contact(initiator, recipient, message = "")
    UserMailer.contact(initiator, recipient, message).deliver
    c = new
    c.initiator = initiator
    c.recipient = recipient
    c.save!
  end
end
