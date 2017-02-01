module Arbre

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

    def cat(output_buffer)
      each { |element| element.cat_or_to_s(output_buffer) }
      output_buffer
    end
  end

end
