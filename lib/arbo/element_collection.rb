module Arbo

  # Stores a collection of Element objects
  class ElementCollection < Array

    def +(other)
      self.class.new(super)
    end

    def -(other)
      self.class.new(super)
    end

    def &(other)
      self.class.new(super)
    end

    def to_s
      self.collect do |element|
        element.to_s
      end.join('').html_safe
    end

    def render_in(context)
      self.collect do |element|
        element.render_in(context)
      end.join('').html_safe
    end
  end

end
