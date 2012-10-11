
module Prawnder
  module ActionControllerMixin
    DEFAULT_PRAWN_PDF_OPTIONS = {:inline=>true}

    #--------------------------------------------------------------------------------------------------#

    def self.included(base)
      base.send :attr_reader, :prawnder_options
      base.class_attribute :prawn_hash, :prawnder_hash
      base.prawn_hash = {}
      base.prawnder_hash = {}
      base.extend ClassMethods
    end

    #--------------------------------------------------------------------------------------------------#

    module ClassMethods

      # This is the class setter. It lets you set default options for all prawn actions within a controller.
      def prawnder(options)
        prawn_options, prawnder_options = breakdown_prawnder_options options
        self.prawn_hash = prawn_options
        self.prawnder_hash = DEFAULT_PRAWN_PDF_OPTIONS.dup.merge(prawnder_options)
      end

      #--------------------------------------------------------------------------------------------------#

      private

      # splits the :prawn key out into a seperate hash
      def breakdown_prawnder_options(options)
        prawnder_options = options.dup
        prawn_options = (prawnder_options.delete(:prawn) || {}).dup
        [prawn_options, prawnder_options]
      end
    end

    #--------------------------------------------------------------------------------------------------#

    # Sets the prawn options. Use in the controller method.
    #
    # respond_to {|format|
    #   format.pdf { prawnder(:page_orientation => :landscape) }
    # }
    def prawnder(options)
      @prawnder_options ||= {}
      @prawnder_options.merge! options
    end

    #--------------------------------------------------------------------------------------------------#

    private

    # this merges the default prawnder options, the controller prawnder options, and the instance prawnder options, and the splits out then joins in the :prawn options.
    # This is called when setting the header information just before render.
    def compute_prawnder_options
      @prawnder_options ||= DEFAULT_PRAWN_PDF_OPTIONS.dup
      @prawnder_options[:prawn] ||= {}
      @prawnder_options[:prawn].merge!(self.class.prawn_hash || {}) {|k,o,n| o}
      @prawnder_options.merge!(self.class.prawnder_hash || {}) {|k,o,n| o}
      @prawnder_options
    end
  end
end


