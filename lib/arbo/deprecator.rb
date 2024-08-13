require 'active_support/deprecation'

module Arbo
  module_function
  def deprecator # :nodoc:
    @deprecator ||= ActiveSupport::Deprecation.new
  end
end
