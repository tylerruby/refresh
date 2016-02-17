json.array! @orders do |order|
  json.(order,
        :id,
        :status,
        :amount_cents,
        :amount_currency,
        :created_at,
        :delivery_address,
        :observations
       )
end
