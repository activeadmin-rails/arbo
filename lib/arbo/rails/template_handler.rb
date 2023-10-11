# frozen_string_literal: true

ActionView::Base.class_eval do
  def capture(*args)
    value = nil
    buffer = with_output_buffer { value = yield(*args) }

    case string = buffer.presence || value
    when ActionView::OutputBuffer
      string.to_s
    when ActiveSupport::SafeBuffer
      string
    when Arbo::Element
      # Override to handle Arbo elements inside helper blocks.
      # See https://github.com/rails/rails/issues/17661
      # and https://github.com/rails/rails/pull/18024#commitcomment-8975180
      value.render_in
    when String
      ERB::Util.html_escape(string)
    end
  end
end

module Arbo
  module Rails
    class TemplateHandler
      def call(template, source = nil)
        source = template.source unless source

        <<-END
        Arbo::Context.new(assigns, self) {
          #{source}
        }.render_in(self).html_safe
        END
      end
    end
  end
end

ActionView::Template.register_template_handler :arb, Arbo::Rails::TemplateHandler.new
