require 'arbo/element/builder_methods'
require 'arbo/element/proxy'
require 'arbo/element_collection'
require 'ruby2_keywords'

module Arbo

  class Element
    include BuilderMethods

    attr_reader :parent
    attr_reader :children, :arbo_context

    def initialize(arbo_context = Arbo::Context.new)
      @arbo_context = arbo_context
      @children = ElementCollection.new
      @parent = nil
    end

    def assigns
      arbo_context.assigns
    end

    def helpers
      arbo_context.helpers
    end

    def tag_name
      @tag_name ||= self.class.name.demodulize.downcase
    end

    def build(*args, &block)
      # Render the block passing ourselves in
      append_return_block(block.call(self)) if block
    end

    def add_child(child)
      return unless child

      if child.is_a?(Array)
        child.each{|item| add_child(item) }
        return @children
      end

      # If its not an element, wrap it in a TextNode
      unless child.is_a?(Element)
        child = Arbo::HTML::TextNode.from_string(child)
      end

      if child.respond_to?(:parent)
        # Remove the child
        child.parent.remove_child(child) if child.parent && child.parent != self
        # Set ourselves as the parent
        child.parent = self
      end

      @children << child
    end

    def remove_child(child)
      child.parent = nil if child.respond_to?(:parent=)
      @children.delete(child)
    end

    def <<(child)
      add_child(child)
    end

    def children?
      @children.any?
    end

    def parent=(parent)
      @parent = parent
    end

    def parent?
      !@parent.nil?
    end

    def ancestors
      if parent?
        [parent] + parent.ancestors
      else
        []
      end
    end

    # TODO: Shouldn't grab whole tree
    def find_first_ancestor(type)
      ancestors.find{|a| a.is_a?(type) }
    end

    def content=(contents)
      clear_children!
      add_child(contents)
    end

    def get_elements_by_tag_name(tag_name)
      elements = ElementCollection.new
      children.each do |child|
        elements << child if child.tag_name == tag_name
        elements.concat(child.get_elements_by_tag_name(tag_name))
      end
      elements
    end
    alias_method :find_by_tag, :get_elements_by_tag_name

    def get_elements_by_class_name(class_name)
      elements = ElementCollection.new
      children.each do |child|
        elements << child if child.class_list.include?(class_name)
        elements.concat(child.get_elements_by_class_name(class_name))
      end
      elements
    end
    alias_method :find_by_class, :get_elements_by_class_name

    def content
      children.to_s
    end

    def html_safe
      to_s
    end

    def indent_level
      parent? ? parent.indent_level + 1 : 0
    end

    def each(&block)
      [to_s].each(&block)
    end

    def inspect
      content
    end

    def to_str
      Arbo.deprecator.warn("don't rely on implicit conversion of Element to String")
      content
    end

    def to_s
      Arbo.deprecator.warn("#render_in should be defined for rendering #{method_owner(:to_s)} instead of #to_s")
      content
    end

    # Rendering strategy that visits all elements and appends output to a buffer.
    def render_in(context = arbo_context)
      children.collect do |element|
        element.render_in_or_to_s(context)
      end.join('')
    end

    # Use render_in to render element unless closer ancestor overrides :to_s only.
    def render_in_or_to_s(context)
      if method_distance(:render_in) <= method_distance(:to_s)
        render_in(context)
      else
        Arbo.deprecator.warn("#render_in should be defined for rendering #{method_owner(:to_s)} instead of #to_s")
        to_s.tap { |s| context.output_buffer << s }
      end
    end

    def +(element)
      case element
      when Element, ElementCollection
      else
        element = Arbo::HTML::TextNode.from_string(element)
      end
      to_ary + element
    end

    def to_ary
      ElementCollection.new [Proxy.new(self)]
    end
    alias_method :to_a, :to_ary

    private

    # Resets the Elements children
    def clear_children!
      @children.clear
    end

    # Implements the method lookup chain. When you call a method that
    # doesn't exist, we:
    #
    #  1. Try to call the method on the current DOM context
    #  2. Return an assigned variable of the same name
    #  3. Call the method on the helper object
    #  4. Call super
    #
    ruby2_keywords def method_missing(name, *args, &block)
      if current_arbo_element.respond_to?(name)
        current_arbo_element.send name, *args, &block
      elsif assigns && assigns.has_key?(name)
        assigns[name]
      elsif helpers.respond_to?(name)
        helper_capture(name, *args, &block)
      else
        super
      end
    end

    # The helper might have a block that builds Arbo elements
    # which will be rendered (#to_s) inside ActionView::Base#capture.
    # We do not want such elements added to self, so we push a dummy
    # current_arbo_element.
    ruby2_keywords def helper_capture(name, *args, &block)
      s = ""
      within(Element.new) { s = helpers.send(name, *args, &block) }
      s.is_a?(Element) ? s.to_s : s
    end

    def method_distance(name)
      self.class.ancestors.index method_owner(name)
    end

    def method_owner(name)
      self.class.instance_method(name).owner
    end
  end
end
