module CartHelper
  def shipping_cost_radio_button(cart, hours)
    shipping_cost = humanized_money_with_symbol cart.shipping_cost_for(hours)
    label = [hours, 'hour'.pluralize(hours), "(+#{shipping_cost})"].join(' ')
    styled_radio_button 'delivery_time', hours, label, required: ''
  end
end
