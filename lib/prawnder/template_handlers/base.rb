require "prawn"

module Prawnder
  module TemplateHandlers
    class Base
      def self.call(template)
        check_for_pdf_redefine(template.source)

        "_prawnder_compile_setup;" +
        "renderer = Prawnder::TemplateHandlers::Renderer.new(self);"+
        "renderer.to_pdf(self) do; #{template.source}\nend;"
      end

    private

      def self.check_for_pdf_redefine(template_source)
        if template_source =~ /pdf\s*=[^=]/
          Rails.logger.warn "\nPrawnder: Possible reassignment of 'pdf' in your .prawn template. Please use the :prawnder method in your controller\n"
        end
      end
    end
  end
end


