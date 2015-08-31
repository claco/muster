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
      def initialize(options = {})
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
      def parse(query_string)
        parameters = Muster::Results.new(fields_to_parse(query_string))

        parameters.each do |key, value|
          parameters[key] = separate_expressions(value)
          parameters[key] = separate_fields(parameters[key])
        end

        parameters
      end

      protected

      # Separates values into an Array of expressions using :expression_separator
      #
      # @param expression [String,Array] the original query string field value to separate
      #
      # @return [String,Array] String if a single value exists, Array otherwise
      #
      # @example
      #
      #   value = separate_values('where=id:1')       #=> {'where' => 'id:1'}
      #   value = separate_values('where=id:1,id:2')  #=> {'where' => ['id:1', 'id:2']}
      def separate_expressions(expression)
        values = Array.wrap(expression)

        values = values.map do |value|
          value.split(expression_separator)
        end.flatten

        (values.size > 1) ? values : values.first
      end

      # Separates expression field values into an Hash of expression filters using :field_separator
      #
      # @param values_string [String,Array] the expressions field value to separate
      #
      # @return [Hash]
      #
      # @example
      #
      #   value = separate_fields('id:1')    #=> {'id' => '1'}
      #   value = separate_values('id:1|2')  #=> {'id' => '1|2'}
      def separate_fields(values_string)
        values = Array.wrap(values_string)

        filters = {}

        values.each do |value|
          name, value = value.split(field_separator, 2)
          value = separate_values(value)

          filters[name] = filters.key?(name) ? [filters[name], value].flatten : value

          filters[name] = ensure_unique_values(filters[name])
        end

        filters
      end

      # Separates expression filter values into an Array of expression filter values using :value_separator
      #
      # @param values_string [String,Array] the expressions filter value to separate
      #
      # @return [String,Array] String if a single value exists, Array otherwise
      #
      # @example
      #
      #   value = separate_values('1')    #=> '1'
      #   value = separate_values('1|2')  #=> ['1', '2']
      def separate_values(values_string)
        values = Array.wrap(values_string)

        values = values.map do |value|
          value.split(value_separator)
        end.flatten

        (values.size > 1) ? values : values_string
      end

      # Ensures that if an Array is given, the values are unique if unique_values is set.
      #
      # @param values [String,Array] the expressions filter values to ensure are unique
      #
      # @return [String,Array] String if a single value exists, Array otherwise
      #
      # @example
      #
      #   value = ensure_unique_values('1')    #=> '1'
      #   value = ensure_unique_values(['1', '2'])  #=> ['1', '2']
      #   value = ensure_unique_values(['1', '1'])  #=> ['1']
      def ensure_unique_values(values)
        if unique_values && values.instance_of?(Array)
          values.uniq
        else
          values
        end
      end
    end
  end
end
