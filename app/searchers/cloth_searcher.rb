class ClothSearcher
  def initialize(search_params)
    self.chain_id = search_params.fetch(:chain_id, nil)
    self.category_id = search_params.fetch(:category_id, nil)
    self.size = search_params.fetch(:size, nil)
    self.max_price = search_params.fetch(:max_price, nil)
  end

  def clothes
    return @clothes unless @clothes.nil?

    @clothes = Cloth.all

    if by_chain?
      @clothes = @clothes.where(chain_id: chain_id)
    end

    if by_category?
      @clothes = @clothes.where(category_id: category_id)
    end

    if by_size?
      @clothes = @clothes.includes(:cloth_variants)
                 .where(cloth_variants: { size: size })
    end

    if by_max_price?
      @clothes = @clothes.where(price_cents: 0..max_price)
    end

    @clothes
  end

  def sizes
    if show_sizes?
      ClothVariant.select(:size)
      .where(cloth: clothes)
      .distinct
      .map(&:size)
    else
      []
    end
  end

  private

    attr_accessor :chain_id, :category_id, :size, :max_price

    def max_price
      @max_price.present? && @max_price.to_money.cents
    end

    def by_chain?
      chain_id.present?
    end

    def by_category?
      category_id.present?
    end

    def by_size?
      size.present?
    end

    def by_max_price?
      max_price.present?
    end

    def show_sizes?
      category_id.present? && size.blank?
    end
end
