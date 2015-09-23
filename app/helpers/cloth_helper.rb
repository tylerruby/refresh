module ClothHelper
  def serialize_colors(cloth_variants)
    cloth_variants.map do |cloth_variant|
      {
        id: cloth_variant.id,
        color: cloth_variant.color
      }
    end.to_json
  end
end
