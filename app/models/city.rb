class City < ActiveRecord::Base
  has_many :addresses, dependent: :nullify

  def name=(value)
    super(value.strip)
  end

  def state=(value)
    super(value.strip)
  end

  def full_name
    "#{name}/#{state}"
  end
end
