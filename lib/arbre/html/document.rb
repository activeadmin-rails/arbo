module Arbre
  module HTML

    class Document < Tag

      def build(*args)
        super
        build_head
        build_body
      end

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

      protected

      def build_head
        @head = head do
          meta :"http-equiv" => "Content-type", content: "text/html; charset=utf-8"
        end
      end

      def build_body
        @body = body
      end
    end

  end
end
