module Prawnder
  class Railtie < Rails::Railtie

    # This runs once during initialization.
    # Register the MimeType and the two template handlers.
    initializer "prawnder.register_handlers" do
      Mime::Type.register("application/pdf", :pdf) unless Mime::Type.lookup_by_extension(:pdf)

      ActiveSupport.on_load(:action_view) do
        ActionView::Template.register_template_handler :prawn, Prawnder::TemplateHandlers::Base
        ActionView::Template.register_template_handler :prawn_dsl, Prawnder::TemplateHandlers::Base # for legacy systems
      end
    end

    # This will run it once in production and before each load in development.
    # Include the mixins for ActionController and ActionView.
    config.to_prepare do
      ActionController::Base.send :include, Prawnder::ActionControllerMixin
      ActionMailer::Base.send :include, Prawnder::ActionControllerMixin
      ActionView::Base.send :include, Prawnder::ActionViewMixin
    end

  end
end
