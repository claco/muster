require 'active_support/hash_with_indifferent_access'
require 'active_support/core_ext/array/wrap'
require 'muster/strategies/hash'

module Muster
  module Strategies
    class SortExpression < Hash

      def parse( query_string )
        parameters  = super
        expressions = ActiveSupport::HashWithIndifferentAccess.new

        parameters.inject(expressions) do |expressions, (key, values)|
          Array.wrap(values).each do |value|
            name, direction = value.to_s.split(':', 2)

            direction  = self.parse_direction(direction)
            expression = "#{name} #{direction}"

            expressions[key] = (expressions.has_key?(key)) ? expressions[key] = [expressions[key], expression].flatten : expression 
          end

          expressions
        end
      end

      def parse_direction( direction )
        direction.to_s.match(/^desc/i) ? 'desc' : 'asc'
      end

    end
  end
end
