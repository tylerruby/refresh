class ClothSearcher
  def initialize(search_params)
    self.chain_id    = search_params[:chain_id]
    self.gender      = search_params[:gender]
    self.category_id = search_params[:category_id]
    self.size        = search_params[:size]
    self.max_price   = search_params[:max_price]
    self.stores      = Store.where(id: search_params[:stores].map(&:id) || [])
                       .includes(chain: :clothes)
  end

  def clothes
    return @clothes unless @clothes.nil?

    if by_chain?
      @clothes = Cloth.where(chain_id: chain_id)
    else
      @clothes = available_for_delivery
    end

    if by_gender?
      @clothes = @clothes.joins(:category).where(categories: gender_condition)
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

    @clothes = @clothes.includes(:cloth_variants).sort_by(&:last_week_views).reverse!
    @clothes.each do |cloth|
      cloth.store = stores.find do |store|
        store.chain == cloth.chain
      end
    end

    @clothes
  end

  def sizes
    if by_category?
      ClothVariant.select(:size)
      .joins(cloth: :category)
      .where(clothes: { category_id: category_id })
      .distinct
      .map(&:size)
    else
      []
    end
  end

  private

    attr_accessor :chain_id, :gender, :category_id, :size, :max_price, :stores

    def max_price
      @max_price.present? && @max_price.to_money.cents
    end

    def by_chain?
      chain_id.present?
    end

    def by_gender?
      gender.present?
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

    def available_for_delivery
      clothes_ids = stores
                    .map(&:chain)
                    .uniq
                    .map(&:clothes)
                    .flat_map {|q| q.select(:id).map(&:id) }

      Cloth.where(id: clothes_ids)
    end

    def gender_condition
      case gender
      when 'male' then { male: true }
      when 'female' then { female: true }
      else {}
      end
    end
end
