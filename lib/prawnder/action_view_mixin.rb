
module Prawnder
  module ActionViewMixin

    private

    def _prawnder_compile_setup
      compile_support = CompileSupport.new(controller)
      @prawnder_options = compile_support.options
    end

  end
end

