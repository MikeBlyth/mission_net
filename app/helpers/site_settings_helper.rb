module SiteSettingsHelper

  def settings_field(field, params={})
    label = params[:label] || field.to_s.humanize
    field_type = params[:field_type]
    boolean = field_type == :boolean
    label << '?' if field_type == :boolean
    input_field = case
      when field.to_s =~ /password/ || params[:password]
        password_field_tag(field, SiteSetting[field])
      when field_type == :boolean
        check_box_tag(field, SiteSetting[field])
      when params[:choices]
        
        select_tag(field, options_for_select(params[:choices], SiteSetting[field]))
      else
        text_field_tag(field, SiteSetting[field])
    end
    ("<div class='site_setting' id='#{field}_form'>".html_safe +
    label_tag(field, label) +
    (field_type == :boolean ? '' : "<br>".html_safe) +
    input_field +
    "</div>".html_safe
    )
  end

end
