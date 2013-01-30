
module Prawnder
  class CompileSupport
    attr_reader :options

    #--------------------------------------------------------------------------------------------------#

    def initialize(controller)
      @controller = controller
      @options = pull_options
      set_headers
    end

    #--------------------------------------------------------------------------------------------------#

    def pull_options
      @controller.send :compute_prawnder_options || {}
    end

    #--------------------------------------------------------------------------------------------------#

    def set_headers
      if @controller.respond_to?(:headers)
        if not called_from_view_spec? and not called_from_mailer?
          set_pragma
          set_cache_control
          set_content_type
          set_disposition
          set_other_headers_for_ie_ssl
        end
      end
    end

    #--------------------------------------------------------------------------------------------------#

    def called_from_mailer?
      defined?(ActionMailer) && defined?(ActionMailer::Base) && @controller.is_a?(ActionMailer::Base)
    end

    #--------------------------------------------------------------------------------------------------#

    def called_from_view_spec?
      defined?(ActionView::TestCase) && defined?(ActionView::TestCase::TestController) && @controller.is_a?(ActionView::TestCase::TestController)
    end

    #--------------------------------------------------------------------------------------------------#

    def ie_request?
      @controller.respond_to?(:request) ? @controller.request.env['HTTP_USER_AGENT'] =~ /msie/i : false
    end

    #--------------------------------------------------------------------------------------------------#

    def ssl_request?
      @controller.respond_to?(:request) ? @controller.request.ssl? : false
    end

    #--------------------------------------------------------------------------------------------------#

    def set_other_headers_for_ie_ssl
      if @controller.respond_to?(:headers)
        return unless ssl_request? && ie_request?
        @controller.headers['Content-Description'] = 'File Transfer'
        @controller.headers['Content-Transfer-Encoding'] = 'binary'
        @controller.headers['Expires'] = '0'
      end
    end

    #--------------------------------------------------------------------------------------------------#

    # TODO: kept around from railspdf-- maybe not needed anymore? should check.
    def set_pragma
      if @controller.respond_to?(:headers)
        if ssl_request? && ie_request?
          @controller.headers['Pragma'] = 'public' # added to make ie ssl pdfs work (per naisayer)
        else
          @controller.headers['Pragma'] ||= ie_request? ? 'no-cache' : ''
        end
      end
    end

    #--------------------------------------------------------------------------------------------------#

    # TODO: kept around from railspdf-- maybe not needed anymore? should check.
    def set_cache_control
      if @controller.respond_to?(:headers)
        if ssl_request? && ie_request?
          @controller.headers['Cache-Control'] = 'maxage=1' # added to make ie ssl pdfs work (per naisayer)
        else
          @controller.headers['Cache-Control'] ||= ie_request? ? 'no-cache, must-revalidate' : ''
        end
      end
    end

    #--------------------------------------------------------------------------------------------------#

    def set_content_type
      if @controller.respond_to?(:headers)
        @controller.response.content_type ||= Mime::PDF
      end
    end

    #--------------------------------------------------------------------------------------------------#

    def set_disposition
      if @controller.respond_to?(:headers)
        inline = options[:inline] ? 'inline' : 'attachment'
        filename = options[:filename] ? "filename=\"#{options[:filename]}\"" : nil
        @controller.headers["Content-Disposition"] = [inline,filename].compact.join(';')
      end
    end

  end
end



