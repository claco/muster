require 'active_support/hash_with_indifferent_access'
require 'active_support/core_ext/array/wrap'
require 'muster/strategies/hash'

module Muster
  module Strategies
    class FilterExpression < Hash

      def parse( query_string )
        parameters  = super
        expressions = ActiveSupport::HashWithIndifferentAccess.new

        parameters.inject(expressions) do |expressions, (key, values)|
          Array.wrap(values).each do |value|
            name, value = value.to_s.split(':', 2)

            value = value.to_s.split('|') if value.include?('|')

            expressions[key] ||= {}
            expressions[key][name] = (expressions[key].has_key?(name)) ? [expressions[key][name], value].flatten.uniq : value
          end

          expressions
        end

      end
    end
  end
end
