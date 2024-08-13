require 'active_support/core_ext/string/output_safety'
require 'active_support/hash_with_indifferent_access'
require 'active_support/inflector'

module Arbo
end

require 'arbo/element'
require 'arbo/context'
require 'arbo/deprecator'
require 'arbo/html/attributes'
require 'arbo/html/class_list'
require 'arbo/html/tag'
require 'arbo/html/text_node'
require 'arbo/html/document'
require 'arbo/html/html5_elements'
require 'arbo/component'

if defined?(Rails)
  require 'arbo/rails'
end
