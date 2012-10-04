
require 'prawnder/version'
require 'prawnder/railtie' if defined?(Rails)

module Prawnder
  autoload :ActionControllerMixin, 'prawnder/action_controller_mixin'
  autoload :ActionViewMixin, 'prawnder/action_view_mixin'
  autoload :CompileSupport, 'prawnder/compile_support'


  module TemplateHandlers
    autoload :Renderer, 'prawnder/template_handlers/renderer'

    autoload :Base, 'prawnder/template_handlers/base'
    autoload :Dsl, 'prawnder/template_handlers/dsl'
  end

  autoload :ModelRenderer, 'prawnder/model_renderer'

end
