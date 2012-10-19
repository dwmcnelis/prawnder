
module Prawnder
  module TemplateHandlers
    module Partials

      class PartialError < StandardError; end

      #--------------------------------------------------------------------------------------------------#

      # Can be called within a prawn template to render a partial in place.
      # :partial Path from the views folder. Doesn't recognize the folder of the current template.
      # :prawn   The object to use for the pdf object in the partial.
      #          Defaults to the pdf document, but can take a paramenter to render within a prawn object. This
      #          is good for items like tables, text_blocks, etc.
      # :locals  Hash of local variables passed to partial
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
          raise PartialError, "render array not yet implemented"
        else
          raise PartialError, "unsupported arguments"
        end
        partial = options[:partial] || nil
        raise PartialError, "partial not specified" unless partial
        prawn = options[:prawn] || pdf
        @locals_stack ||= []
        @locals_stack.push @locals
        @locals = options[:locals]
        @pdf_stack ||= []
        @pdf_stack.push @pdf
        @pdf = prawn
        instance_eval partial_source(partial)
        @pdf = @pdf_stack.pop
        @locals = @locals_stack.pop
      end

      #--------------------------------------------------------------------------------------------------#

      private

      def partial_source(partial_name)
        #TODO: implement some caching
        File.open(get_file_path(partial_name)).read
      end

      #--------------------------------------------------------------------------------------------------#

      def get_file_path(partial_name)
        partial_pathname = Pathname.new(partial_name)
        Dir[File.join(Rails.root,"app/views/",partial_pathname.dirname,"_"+partial_pathname.basename.to_s+".{*.}prawn")].first
      end

    end
  end
end
