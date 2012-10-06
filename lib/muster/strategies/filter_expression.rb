require 'active_support/core_ext/array/wrap'
require 'muster/results'
require 'muster/strategies/hash'

module Muster
  module Strategies

    # Query string parsing strategy with additional value handling options for separating filtering expressions
    #
    # @example
    #
    #   strategy = Muster::Strategies::FilterExpression.new
    #   results  = strategy.parse('where=id:1&name:Bob')  #=>  { 'where' => {'id' => '1', 'name' => 'Bob'} }
    class FilterExpression < Muster::Strategies::Hash

      # @attribute [r] expression_separator
      # @return [String,RegEx] when specified, each field value will be split into multiple expressions using the specified separator
      attr_reader :expression_separator
      
      # @attribute [r] field_separator
      # @return [String,RegEx] when specified, each expression will be split into multiple field/values using the specified separator
      attr_reader :field_separator

      # Create a new Hash parsing strategy
      #
      # @param [Hash] options the options available for this method
      # @option options [optional,Array<Symbol>] :fields when specified, only parse the specified fields
      #  You may also use :field if you only intend to pass one field
      # @option options [optional,String,RegEx] :expression_separator (/,\s*/) when specified, splits the query string value into multiple expressions
      #  You may pass the separator as a string or a regular expression
      # @option options [optional,String,RegEx] :field_separator (:) when specified, splits the expression value into multiple field/values
      #  You may pass the separator as a string or a regular expression
      # @option options [optional,String,RegEx] :value_separator (|) when specified, splits the field value into multiple values
      #  You may pass the separator as a string or a regular expression
      # @option options [optional,Boolean] :unique_values (true) when true, ensures field values do not contain duplicates
      #
      # @example
      #
      #   strategy = Muster::Strategies::FilterExpression.new
      #   strategy = Muster::Strategies::FilterExpression.new(:unique_values => false)
      def initialize( options={} )
        super

        @expression_separator = self.options.fetch(:expression_separator, /,\s*/)
        @field_separator = self.options.fetch(:field_separator, ':')
        @value_separator = self.options.fetch(:value_separator, '|')
      end

      # Processes a query string and returns a hash of its fields/values
      #
      # @param query_string [String] the query string to parse
      #
      # @return [Muster::Results]
      #
      # @example
      #   
      #   results = strategy.parse('where=id:1&name:Bob')  #=>  { 'where' => {'id' => '1', 'name' => 'Bob'} }
      def parse( query_string )
        parameters = Muster::Results.new( self.fields_to_parse(query_string) )

        parameters.each do |key, value|
          parameters[key] = self.separate_expressions(value)
          parameters[key] = self.separate_fields(parameters[key])
        end

        return parameters
      end

      protected

      # Separates values into an Array of expressions using :expression_separator
      #
      # @param value [String,Array] the original query string field value to separate
      #
      # @return [String,Array] String if a single value exists, Array otherwise
      #
      # @example
      #
      #   value = self.separate_values('where=id:1')       #=> {'where' => 'id:1'}
      #   value = self.separate_values('where=id:1,id:2')  #=> {'where' => ['id:1', 'id:2']}
      def separate_expressions( value )
        values = Array.wrap(value)

        values = values.map do |value|
          value.split(self.expression_separator)
        end.flatten

        return (values.size > 1) ? values : values.first
      end

      # Separates expression field values into an Hash of expression filters using :field_separator
      #
      # @param value [String,Array] the expressions field value to separate
      #
      # @return [Hash]
      #
      # @example
      #
      #   value = self.separate_fields('id:1')    #=> {'id' => '1'}
      #   value = self.separate_values('id:1|2')  #=> {'id' => '1|2'}
      def separate_fields( value )
        values = Array.wrap(value)
        
        filters = {}

        values.each do |value|
          name, value = value.split(self.field_separator, 2)

          if self.value_separator.present?
            value = self.separate_values(value)
          end

          filters[name] = filters.has_key?(name) ? [filters[name], value].flatten : value

          if self.unique_values == true && filters[name].instance_of?(Array)
            filters[name].uniq!
          end
        end

        return filters
      end

      # Separates expression filter values into an Array of expression filter values using :value_separator
      #
      # @param value [String,Array] the expressions filter value to separate
      #
      # @return [String,Array] String if a single value exists, Array otherwise
      #
      # @example
      #
      #   value = self.separate_values('1')    #=> '1'
      #   value = self.separate_values('1|2')  #=> ['1', '2']
      def separate_values( value )
        values = Array.wrap(value)

        values = values.map do |value|
          value.split(self.value_separator)
        end.flatten

        return (values.size > 1) ? values : value
      end

    end
  end
end
