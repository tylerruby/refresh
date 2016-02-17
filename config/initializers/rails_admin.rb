RailsAdmin.config do |config|

  ### Popular gems integration

  ## == Devise ==
  config.authenticate_with do
    warden.authenticate! scope: :user
  end
  config.current_user_method(&:current_user)

  ## == Cancan ==
  # config.authorize_with :cancan
  config.authorize_with do
    redirect_to main_app.root_path unless current_user.admin?
  end

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  RailsAdmin::Config::Actions.register(RailsAdmin::Config::Actions::Refund)

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app
    refund

    member :mark_as_delivered do
      only 'Order'
      link_icon 'icon-check'

      register_instance_option(:visible?) do
        bindings[:object].is_a?(Order) && bindings[:object].on_the_way?
      end

      register_instance_option(:controller) do
        proc { object.delivered!; redirect_to :back }
      end
    end

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end
end
