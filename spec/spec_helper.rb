require 'support/bundle'

require 'arbo'

def arbo(&block)
  Arbo::Context.new assigns, helpers, &block
end
