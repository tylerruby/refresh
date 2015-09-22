module ApplicationHelper
  def modal_id(record)
    "#{record.class.name.downcase}_modal_#{record.id}"
  end

  def styled_radio_button(name, value, label, options = {})
    content_tag :div, class: :radio do
      content_tag :label do
        concat radio_button_tag name, value, false, options
        concat label
      end
    end
  end
end
