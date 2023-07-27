module Arbo
  module Rails
    module Rendering

      def render(*args)
        rendered = helpers.render(*args)
        case rendered
        when Arbo::Context
          current_arbo_element.add_child rendered
        else
          text_node rendered
        end
      end

    end
  end
end
