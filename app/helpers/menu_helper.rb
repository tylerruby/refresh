module MenuHelper
  def list_item_to_menu(menu, offset)
    date = Date.current + offset.days
    klass = 'active' if date == menu.date
    content_tag(:li, link_to_menu(date), class: klass)
  end

  def link_to_menu(date)
    link_to label_for_date(date), menu_path(date: date)
  end

  def label_for_date(date)
    today = Date.current
    case date
    when today then 'Today'
    when today + 1.day then 'Tomorrow'
    else
      date.strftime('%A')
    end
  end
end
