module ApplicationHelper
  
  # https://coderwall.com/p/suyeew
  def resource_error_messages!(resource)
    return '' if resource.errors.empty?

    messages = resource.errors.full_messages.map {|msg| content_tag(:li, msg)}.join
    sentence = I18n.t('errors.messages.not_saved',
      :count => resource.errors.count,
      :resource => resource.class.model_name.human.downcase)

    %Q{
    <div class="alert alert-error alert-block">
      <button type="button" class="close" data-dismiss="alert">x</button>
      <h4>#{sentence}</h4>
      #{messages}
    </div>
}.html_safe
  end
  
  def more_link(*args)
    raw("<span class=\"about-link\">" + link_to(raw("more &raquo;"), *args) + "</span>")
  end
  

  
end
