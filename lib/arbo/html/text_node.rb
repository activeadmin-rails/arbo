require 'erb'

module Arbo
  module HTML

    class TextNode < Element

      builder_method :text_node

      # Builds a text node from a string
      def self.from_string(string)
        node = new
        node.build(string)
        node
      end

      def add_child(*args)
        raise "TextNodes do not have children"
      end

      def build(string)
        @content = string
      end

      def class_list
        []
      end

      def tag_name
        nil
      end

      def to_s
        ERB::Util.html_escape(@content.to_s)
      end

      def render_in(context)
        to_s.tap { |s| context.output_buffer << s }
      end
    end

  end
end
