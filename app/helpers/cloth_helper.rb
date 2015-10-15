module ClothHelper
  def size_options_for(cloth)
    cloth.cloth_variants.group_by(&:size).map do |size, cloth_variants|
      content_tag(:option, size, value: size, data: { 'cloth-variants' => serialize_colors(cloth_variants) })
    end.join.html_safe
  end

  def serialize_colors(cloth_variants)
    cloth_variants.map do |cloth_variant|
      {
        id: cloth_variant.id,
        color: cloth_variant.color
      }
    end.to_json
  end

  def gender_name(gender)
    case gender
    when 'male' then "Men's"
    when 'female' then "Women's"
    end
  end
end
