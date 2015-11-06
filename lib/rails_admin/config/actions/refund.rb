module RailsAdmin
  module Config
    module Actions
      class Refund < Base
        register_instance_option :member? do
          true
        end

        register_instance_option :http_methods do
          [:get, :put]
        end

        register_instance_option :only do
          Order
        end

        register_instance_option :link_icon do
          'icon-thumbs-down'
        end

        register_instance_option :visible? do
          !bindings[:object].refunded?
        end

        register_instance_option :controller do
          proc do
            if request.get?

              respond_to do |format|
                format.html { render @action.template_name }
                format.js   { render @action.template_name, layout: false }
              end

            elsif request.put?
              ::Refund.new(order: object, message: params[:message]).create
              respond_to do |format|
                format.html { redirect_to_on_success }
              end
            end
          end
        end
      end
    end
  end
end
