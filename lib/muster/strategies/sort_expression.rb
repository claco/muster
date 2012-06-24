require 'active_support/core_ext/array/wrap'
require 'muster/strategies/hash'

module Muster
  module Strategies

    # Query string parsing strategy with additional value handling for sort orders
    #
    # @example
    #
    #   strategy = Muster::Strategies::SortExpression.new
    #   results  = strategy.parse('sort=name:desc')  #=>  { 'sort' => 'name desc' }
    class SortExpression < Muster::Strategies::Hash

      # Processes a query string and returns a hash of its fields/values
      #
      # @param query_string [String] the query string to parse
      #
      # @return [Hash]
      #
      # @example
      #   
      #   results = strategy.parse('order=name')            #=>  { 'order' => 'name asc' }
      #   results = strategy.parse('order=name:desc')       #=>  { 'order' => 'name desc' }
      #   results = strategy.parse('order=name,date:desc')  #=>  { 'order' => ['name asc', 'date desc'] }
      def parse( query_string )
        parameters  = super

        parameters.each do |key, value|
          parameters[key] = self.parse_sort_expression(value)
        end
      end

      protected

      # Separates the values into their field and direction
      #
      # @param value [String] the value being parsed
      #
      # @return [String,Arrary] String if a single value, Array otherwise
      #
      # @example
      #
      #    value = self.parse_sort_expression('name:asc')  #=>  'name asc'
      #    value = self.parse_sort_expression(['name:asc', 'date'])  #=>  ['name asc', 'date asc']
      def parse_sort_expression( value )
        values = Array.wrap(value)

        values = values.map do |value|
          name, direction = value.split(':', 2)
          direction = self.parse_direction(direction)

          "#{name} #{direction}"
        end.flatten

        return (values.size > 1) ? values : values.first
      end

      # Parse and normalize the sot expression direction
      #
      # @param direction [String] the direction to normalize
      #
      # @return [String]
      #
      # @example
      #
      #   direction = self.parse_direction('ascending')   #=> 'asc'
      #   direction = self.parse_direction('descending')  #=> 'desc'
      def parse_direction( direction )
        direction.to_s.match(/^desc/i) ? 'desc' : 'asc'
      end

    end
  end
end
