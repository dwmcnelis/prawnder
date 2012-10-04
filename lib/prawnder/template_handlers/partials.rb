module Prawnder
  module TemplateHandlers
    module Partials

      # Can be called within a prawn template to render a partial below it.
      # :partial_name - Current has to be the entire path from the views folder. Doesn't recognize the folder of the
      #                 current template.
      # :prawn_object - The object to use for the pdf object in the partial.
      #                 Defaults to the pdf document, but can take a paramenter to render within a prawn object. This
      #                 is good for items like tables, text_blocks, etc.
      def partial!(partial_name, prawn_object = pdf)
        @pdf_stack ||= []
        @pdf_stack.push @pdf
        @pdf = prawn_object
        self.instance_eval { partial_source(partial_name) }
        @pdf = @pdf_stack.pop
      end

    private

      def partial_source(partial_name)
        #TODO: implement some caching
        file_path = get_file_path(partial_name)
        puts "Prawnder: partial_source file_path #{file_path}"
        File.open(file_path).read
      end

      def get_file_path(partial_name)
        partial_pathname = Pathname.new(partial_name)
        partial_dirname = partial_pathname.dirname
        partial_basename = partial_pathname.basename
        file_path = Dir[File.join(Rails.root,"app/views/",partial_dirname,"_"+partial_basename.to_s+".{*.}prawn")].first
        file_path
      end

    end
  end
end
