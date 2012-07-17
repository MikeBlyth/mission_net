module SiteSettingsHelper

  def settings_field(field, params={})
    label = params[:label] || field.to_s.humanize
    if field.to_s =~ /password/ || params[:password]
      input_field = password_field_tag(field, SiteSetting[field])
    else
      input_field = text_field_tag(field, SiteSetting[field])
    end
    ("<div class='site_setting' id='#{field}_form'>".html_safe +
    label_tag(field, label) +
    "<br>".html_safe +
    input_field +
    "</div>".html_safe
    )
  end

end
