module ApplicationHelper
  def body_css_classes
    [
      controller_name.dasherize,
      action_name.dasherize,
      @additional_body_css_classes
    ].reject(&:blank?).join(' ')
  end

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

  def modal_to(title, href, options = {})
    options = {
      data: { toggle: :modal, dismiss: :modal }
    }.merge(options)
    link_to title, href, options
  end

  def dropdown_for(title, options = {})
    tag = options[:tag] || :li
    classes = ['dropdown', options.delete(:class)].compact.join(' ')
    content_tag(tag, { class: classes }.merge(options)) do
      concat (content_tag(:a, 'class' => 'dropdown-toggle', 'data-toggle' => 'dropdown', 'role' => 'button', 'aria-haspopup' => 'true', 'aria-expanded' => 'false') do
        [title, content_tag(:span, nil, class: 'caret')].join(' ').html_safe
      end)

      concat (content_tag(:ul, class: 'dropdown-menu') do
        yield
      end)
    end
  end

  def store_path(store)
    "/atlanta/#{store.friendly_id}"
  end
end
