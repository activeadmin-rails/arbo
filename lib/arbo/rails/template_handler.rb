# frozen_string_literal: true

ActionView::Base.class_eval do
  def capture(*args)
    value = nil
    buffer = with_output_buffer { value = yield(*args) }

    # Override to handle Arbo elements inside helper blocks.
    # See https://github.com/rails/rails/issues/17661
    # and https://github.com/rails/rails/pull/18024#commitcomment-8975180
    value = value.to_s if value.is_a?(Arbo::Element)

    if (string = buffer.presence || value) && string.is_a?(String)
      ERB::Util.html_escape string
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
