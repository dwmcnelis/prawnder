module Prawnder
  module TemplateHandlers
    module Partials

      class RenderError < StandardError; end

      # Can be called within a prawn template to render a partial in place.
      # :partial_name - Current has to be the entire path from the views folder. Doesn't recognize the folder of the
      #                 current template.
      # :prawn_object - The object to use for the pdf object in the partial.
      #                 Defaults to the pdf document, but can take a paramenter to render within a prawn object. This
      #                 is good for items like tables, text_blocks, etc.

      # render partial(String)
      # X render things(Array)
      # render :partial => partial(String), :prawn => prawn(PrawnObject), :locals => {:var1 => value1, :var2 => value2}
      #
      #
      #
      #

      def render(*args)
        options = {}
        if args.length == 1 && args[0].class == String
          # render partial
          options[:partial] = args[0]
        elsif args.length == 1 && args[0].class == Hash
          # render :partial => 'partial', :locals =>  {:var1 => value1, :var2 => value2}
          options = args[0]
        elsif args.length == 2 && args[0].class == String && args[1].class == Hash
          # render 'partial', :var1 => value1, :var2 => value2
          options[:locals] = args[1]
          options[:partial] = args[0]
        elsif args.length == 1 && args[0].class == Array
          # render ['xpartials','ypartials']
          raise RenderError, "render array not yet implemented"
        else
          raise RenderError, "unsupported arguments"
        end
        partial = options[:partial] || nil
        raise RenderError, "partial not specified" unless partial
        prawn = options[:prawn] || pdf
        set_locals(options[:locals], Prawnder::TemplateHandlers::Renderer::PRAWNS+Prawnder::TemplateHandlers::Renderer::PRAWN_CHARTS) if options[:locals]
        @pdf_stack ||= []
        @pdf_stack.push @pdf
        @pdf = prawn
        instance_eval partial_source(partial)
        @pdf = @pdf_stack.pop
        set_locals({})
      end

    private

      def partial_source(partial_name)
        #TODO: implement some caching
        File.open(get_file_path(partial_name)).read
      end

      def get_file_path(partial_name)
        partial_pathname = Pathname.new(partial_name)
        Dir[File.join(Rails.root,"app/views/",partial_pathname.dirname,"_"+partial_pathname.basename.to_s+".{*.}prawn")].first
      end

    end
  end
end
