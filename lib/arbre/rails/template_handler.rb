class ActionView::Base
  # Used to capture helper block contents.
  # Override to handle Arbre elements inside helper blocks.
  def capture(*args)
    value = nil
    buffer = with_output_buffer { value = yield(*args) }
    string = buffer.presence || value
    if string && (String === string || Arbre::Element === string)
      ERB::Util.html_escape string
    end
  end
end

module Arbre
  module Rails
    class TemplateHandler
      def call(template)
        <<-END
        Arbre::Context.new(assigns, self) {
          #{template.source}
        }.cat.tap { |ios| ios.rewind }.read.html_safe
        END
      end
    end
  end
end

ActionView::Template.register_template_handler :arb, Arbre::Rails::TemplateHandler.new
