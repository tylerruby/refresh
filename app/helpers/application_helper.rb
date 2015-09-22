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

  def alert_class_for(key)
    case key.to_s
    when 'notice' then 'alert-info'
    when 'alert' then 'alert-warning'
    when 'errors' then 'alert-danger'
    else
      "alert-#{key}"
    end
  end
end
