module Arbre
  module HTML

    class Document < Tag

      def document
        self
      end

      def tag_name
        'html'
      end

      def doctype
        '<!DOCTYPE html>'.html_safe
      end

      def to_s
        doctype + super
      end

      def render_in(context = arbre_context)
        context.output_buffer << doctype
        super
        context.output_buffer
      end

    end

  end
end
