
require "prawnder/template_handlers/partials"

module Prawnder
  module TemplateHandlers
    class Renderer
      include Partials

      class RenderError < StandardError; end

      #--------------------------------------------------------------------------------------------------#

      def initialize(view_context, calling_object = nil)
        @view_context = view_context
        @calling_object = calling_object
        set_instance_variables
        @pdf = Prawn::Document.new(@prawnder_options[:prawn]);
        @locals = {}
      end

      #--------------------------------------------------------------------------------------------------#

      def to_pdf(scope = false, &block)
        @_scope = scope
        instance_eval(&block)
        @pdf.render.html_safe
      end

      #--------------------------------------------------------------------------------------------------#

      private

      def set_instance_variables
        @calling_object ||= @view_context
        copy_instance_variables_from @calling_object

        if @prawnder_options[:instance_variables_from]
          copy_instance_variables_from @prawnder_options[:instance_variables_from]
        end
      end

      #--------------------------------------------------------------------------------------------------#

      def pdf
        @pdf
      end

      #--------------------------------------------------------------------------------------------------#

      def locals
        @locals
      end

      #--------------------------------------------------------------------------------------------------#

      def image_path(file)
        if defined?(Rails)
          Rails.root.join('app/assets/images',file)
        else
          File.join('/',file)
        end
      end

      #--------------------------------------------------------------------------------------------------#

      def image_fit(image_width,image_height,to_width,to_height)
        scale_width = (to_width.to_f)/(image_width.to_f)
        scale_height = (to_height.to_f)/(image_height.to_f)
        scale =  scale_width <  scale_height ? scale_width : scale_height
        x =  (to_width.to_f-(scale*image_width.to_f))/2.0
        y =  (to_height.to_f-(scale*image_height.to_f))/2.0
        {scale: scale,at: [x,y]}
      end

      #--------------------------------------------------------------------------------------------------#

      # This was removed in Rails 3.1
      def copy_instance_variables_from(object, exclude = [])
        vars = object.instance_variables.map(&:to_s) - exclude.map(&:to_s)
        vars.each { |name| instance_variable_set(name, object.instance_variable_get(name)) }
      end

      #--------------------------------------------------------------------------------------------------#

      def push_instance_variables_to(object, exclude = [])
        vars = instance_variables.map(&:to_s) - exclude.map(&:to_s)
        vars.each { |name| object.instance_variable_set(name, instance_variable_get(name)) }
      end

      #--------------------------------------------------------------------------------------------------#

      # Dynamic methods for access to @pdf,@calling_object,@view_context, and @locals
      def method_missing(method, *args, &block)
        fill_stroke_pattern = /^fill_and_stroke_|^fill_|^stroke_/
        begin
          super
        rescue
          if !@pdf.nil? &&  @pdf.respond_to?(method.to_s)
            # dynamic method for @pdf method
            @pdf.send(method, *args, &block)
          elsif method.to_s.match(fill_stroke_pattern) &&  !@pdf.nil? &&  @pdf.respond_to?(method.to_s.gsub(fill_stroke_pattern,''))
            # dynamic method for @pdf fill_* or stroke_* dynamic method
            @pdf.send(method, *args, &block)
          elsif !@calling_object.nil? &&  @calling_object.respond_to?(method.to_s)
            # dynamic method for @calling_object method
            push_instance_variables_to @calling_object
            res = @calling_object.send(method, *args, &block)
            copy_instance_variables_from @calling_object
            res
          elsif !@calling_object.nil? &&  !@view_context.nil? &&  @calling_object != @view_context and @view_context.respond_to?(method.to_s)
            # dynamic method for @view_context method
            push_instance_variables_to @view_context
            res = @view_context.send(method, *args, &block)
            copy_instance_variables_from @view_context
            res
          elsif !@locals.nil? && @locals.include?(method)
            # dynamic method for locals
            res = @locals[method]
            res
          else
            raise RenderError, "method missing '#{method.to_s}'"
          end
        end
      end

    end
  end
end

