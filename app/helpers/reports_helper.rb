#require 'formatted_columns'

module ReportsHelper
  # Page Header for use by Prawn
  silence_warnings {NBSP = Prawn::Text::NBSP}

  def page_header(options={})
font_families.update(
   "Aller" => { :bold        => "public/fonts/Aller.ttf",
                :italic      => "public/fonts/Aller_It.ttf",
                :bold_italic => "public/fonts/Aller_BdIt.ttf",
                :normal      => "public/fonts/Aller_Rg.ttf" })
    # Main info repeated on every page (see below for page number)
    repeat :all do 
      header_top_margin = bounds.top
      header_left_margin = bounds.left
      header_right_margin = bounds.right

#      font "Aller"  # -- Aller is OK but does not have a non-breaking space, apparently
      draw_text Time.now.strftime("#{I18n.t(:printed_on_date)} %d %b %Y"), :at => [0,0], :size => 8
      font_size(10) do     
        text_box(options[:left] || I18n.t(SiteSetting.directory_title), :height=>20+font.descender, :valign=>:bottom)
      end
      font_size(16) do
        box_height = 20+font.descender
        text_box(options[:title] || I18n.t("Title") , :size=>20, :style=>:bold, :align=>:center, :valign=>:bottom, 
            :height=>box_height)
        move_down box_height + (options[:top_rule_gap] || 2)
      end      
      horizontal_rule()
      stroke
      # rule at bottom of header; if not in its own bounding box, seems not to print in a repeat
    end #repeat :all do
#    # separate repeat for page number since it's dynamic (not that it matters for the amount of work we're doing)
    repeat(:all, :dynamic=> true) do 
      text_box(" #{I18n.t(:Page)} #{page_number}", :size=>10, :align=>:right, :valign=>:bottom, :height=>20)
    end
  end

 

end
