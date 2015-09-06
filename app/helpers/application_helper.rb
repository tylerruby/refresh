module ApplicationHelper
  def modal_id(record)
    "#{record.class.name.downcase}_modal_#{record.id}"
  end
end
