module NameColumnHelper
  def name_form_column(record,params)
    if record.class == Member || record.class == Family
      text_input=text_field_tag 'record[name]', record.name, :id=>params[:id], :class=> "name-input text-input",
        :disabled=>'disabled', :size=>35
      allow_edit = "<a href='#' id='allow_edit_#{params[:id]}' class='allow_edit'>Click to allow editing</a>"
      r = text_input + "\n" + raw(allow_edit)
      return r
    else
      # ! This is workaround for a Rails bug since the modified field above (disabled, with Click to allow editing) is
      # !   showing up on ALL models. If that is fixed, this will not be necessary.
      text_input=text_field_tag 'record[name]', record.name, :id=>params[:id], :class=> "name-input text-input"
    end
  end
end
