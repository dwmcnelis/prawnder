require "prawnder/template_handlers/partials"

module Prawnder
  module TemplateHandlers
    class Renderer
      include Partials

      # Prawn DSL methods to add.
      PRAWNS = %w(bounds bounding_box fill_circle fill_color fill_rectangle font go_to_page lazy_bounding_box line_width move_down page_number page_count repeat start_new_page stroke_color stroke_horizontal_rule stroke_rectangle text text_box transparent)

      #[:bounding_box, :canvas, :column_box, :span, :margin_box, :margin_box=, :margins, :y, :font_size=, :page_number, :page_number=, :state, :page, :start_new_page, :page_count, :go_to_page, :y=, :cursor, :move_cursor_to, :float, :render, :render_file, :bounds, :reference_bounds, :bounds=, :move_up, :move_down, :pad_top, :pad_bottom, :pad, :indent, :mask, :group, :number_pages, :page_match?, :compression_enabled?, :font, :font_size, :set_font, :save_font, :find_font, :font_registry, :font_families, :width_of, :repeaters, :repeat, :outline, :cell, :make_cell, :table, :make_table, :define_grid, :grid, :stamp, :stamp_at, :create_stamp, :move_to, :line_to, :curve_to, :rectangle, :rounded_rectangle, :line_width=, :line_width, :line, :horizontal_line, :horizontal_rule, :vertical_line, :curve, :circle_at, :circle, :ellipse_at, :ellipse, :polygon, :rounded_polygon, :rounded_vertex, :stroke, :close_and_stroke, :stroke_bounds, :fill, :fill_and_stroke, :close_path, :method_missing, :fill_gradient, :stroke_gradient, :rotate, :translate, :scale, :transformation_matrix, :transparent, :join_style, :join_style=, :cap_style, :cap_style=, :dash, :dash=, :undash, :dashed?, :write_stroke_dash, :fill_color, :fill_color=, :stroke_color, :stroke_color=, :text_box, :text, :formatted_text, :draw_text, :height_of, :height_of_formatted, :formatted_text_box, :skip_encoding, :draw_text!, :process_text_options, :default_kerning?, :default_kerning, :default_kerning=, :default_leading, :default_leading=, :text_direction, :text_direction=, :fallback_fonts, :fallback_fonts=, :text_rendering_mode, :character_spacing, :word_spacing, :encrypt_document, :open_graphics_state, :close_graphics_state, :save_graphics_state, :restore_graphics_state, :graphic_stack, :graphic_state, :rollback, :transaction, :dests, :add_dest, :dest_xyz, :dest_fit, :dest_fit_horizontally, :dest_fit_vertically, :dest_fit_rect, :dest_fit_bounds, :dest_fit_bounds_horizontally, :dest_fit_bounds_vertically, :annotate, :text_annotation, :link_annotation, :ref, :ref!, :deref, :add_content, :names, :names?, :before_render, :on_page_create, :psych_to_yaml, :to_yaml_properties, :to_yaml, :in?, :blank?, :present?, :presence, :acts_like?, :try, :html_safe?, :methods, :private_methods, :protected_methods, :public_methods, :singleton_methods, :with_options, :to_param, :to_query, :duplicable?, :to_json, :instance_values, :instance_variable_names, :as_json, :eval_js, :`, :require_or_load, :require_dependency, :require_association, :load_dependency, :load, :require, :unloadable, :pretty_print, :pretty_print_cycle, :pretty_print_instance_variables, :pretty_print_inspect, :nil?, :===, :=~, :!~, :eql?, :hash, :<=>, :class, :singleton_class, :clone, :dup, :initialize_dup, :initialize_clone, :taint, :tainted?, :untaint, :untrust, :untrusted?, :trust, :freeze, :frozen?, :to_s, :inspect, :instance_variables, :instance_variable_get, :instance_variable_set, :instance_variable_defined?, :instance_of?, :kind_of?, :is_a?, :tap, :send, :public_send, :respond_to?, :respond_to_missing?, :extend, :display, :method, :public_method, :define_singleton_method, :object_id, :to_enum, :enum_for, :gem, :silence_warnings, :enable_warnings, :with_warnings, :silence_stderr, :silence_stream, :suppress, :capture, :silence, :quietly, :class_eval, :ai, :awesome_inspect, :awesome_print, :pretty_inspect, :debugger, :breakpoint, :binding_n, :suppress_warnings, :==, :equal?, :!, :!=, :instance_eval, :instance_exec, :__send__, :__id__]
      # PrawnCharts DSL methods to add.
      PRAWN_CHARTS = %w() #stroke_axis

      def initialize(view_context, calling_object = nil)
        @view_context = view_context
        @calling_object = calling_object
        set_instance_variables
        @pdf = Prawn::Document.new(@prawnder_options[:prawn]);
      end

      def to_pdf(scope = false, &block)
        @_scope = scope
        instance_eval(&block)
        @pdf.render.html_safe
      end

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

      # Add prawn DSL methods to renderer for convenience.
      PRAWNS.each do |prawn|
        define_method("#{prawn}") do |*args,&block|
          @pdf.send("#{prawn}", *args,&block)
        end
      end

      #--------------------------------------------------------------------------------------------------#

      # Add prawn DSL methods to renderer for convenience.
      PRAWN_CHARTS.each do |prawn|
        define_method("#{prawn}") do |*args,&block|
          @pdf.send("#{prawn}", *args,&block)
        end
      end

#--------------------------------------------------------------------------------------------------#

      # This was removed in Rails 3.1
      def copy_instance_variables_from(object, exclude = [])
        vars = object.instance_variables.map(&:to_s) - exclude.map(&:to_s)
        vars.each { |name| instance_variable_set(name, object.instance_variable_get(name)) }
      end

      def push_instance_variables_to(object, exclude = [])
        vars = instance_variables.map(&:to_s) - exclude.map(&:to_s)
        vars.each { |name| object.instance_variable_set(name, instance_variable_get(name)) }
      end

      # This method is a little hacky with pushing the instance variables back. I would prefer to use bindings, but wasn't having much luck.
      def method_missing(m, *args, &block)
        begin
          super
        rescue
          if pdf.respond_to?(m.to_s)
            pdf.send(m, *args, &block)
          elsif @calling_object.respond_to?(m.to_s)
            push_instance_variables_to @calling_object
            res = @calling_object.send(m, *args, &block)
            copy_instance_variables_from @calling_object
            res
          elsif @calling_object != @view_context and @view_context.respond_to?(m.to_s)
            push_instance_variables_to @view_context
            res = @view_context.send(m, *args, &block)
            copy_instance_variables_from @view_context
            res
          else
            raise
          end
        end
      end

    end
  end
end

