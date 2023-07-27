require 'arbo/element'
require 'ruby2_keywords'

module Arbo

  # The Arbo::Context class is the frontend for using Arbo.
  #
  # The simplest example possible:
  #
  #     html = Arbo::Context.new do
  #       h1 "Hello World"
  #     end
  #
  #     html.to_s #=> "<h1>Hello World</h1>"
  #
  # The contents of the block are instance eval'd within the Context
  # object. This means that you lose context to the outside world from
  # within the block. To pass local variables into the Context, use the
  # assigns param.
  #
  #     html = Arbo::Context.new({one: 1}) do
  #       h1 "Your number #{one}"
  #     end
  #
  #     html.to_s #=> "Your number 1"
  #
  class Context < Element

    # Initialize a new Arbo::Context
    #
    # @param [Hash] assigns A hash of objecs that you would like to be
    #                       availble as local variables within the Context
    #
    # @param [Object] helpers An object that has methods on it which will become
    #                         instance methods within the context.
    #
    # @yield [] The block that will get instance eval'd in the context
    def initialize(assigns = {}, helpers = nil, &block)
      assigns = assigns || {}
      @_assigns = assigns.symbolize_keys

      @_helpers = helpers
      @_current_arbo_element_buffer = [self]

      super(self)
      instance_eval(&block) if block_given?
    end

    def arbo_context
      self
    end

    def assigns
      @_assigns
    end

    def helpers
      @_helpers
    end

    def indent_level
      # A context does not increment the indent_level
      super - 1
    end

    def bytesize
      cached_html.bytesize
    end
    alias :length :bytesize

    def respond_to_missing?(method, include_all)
      super || cached_html.respond_to?(method, include_all)
    end

    # Webservers treat Arbo::Context as a string. We override
    # method_missing to delegate to the string representation
    # of the html.
    ruby2_keywords def method_missing(method, *args, &block)
      if cached_html.respond_to? method
        cached_html.send method, *args, &block
      else
        super
      end
    end

    def current_arbo_element
      @_current_arbo_element_buffer.last
    end

    def with_current_arbo_element(tag)
      raise ArgumentError, "Can't be in the context of nil. #{@_current_arbo_element_buffer.inspect}" unless tag
      @_current_arbo_element_buffer.push tag
      yield
      @_current_arbo_element_buffer.pop
    end
    alias_method :within, :with_current_arbo_element

    def output_buffer
      @output_buffer ||= ActiveSupport::SafeBuffer.new
    end

    private


    # Caches the rendered HTML so that we don't re-render just to
    # get the content lenght or to delegate a method to the HTML
    def cached_html
      if defined?(@cached_html)
        @cached_html
      else
        html = render_in(self)
        @cached_html = html if html.length > 0
        html
      end
    end

  end
end
