require 'muster/strategies/hash'

module Muster
  module Strategies

    # Query string parsing strategy with additional value handling options for separating filtering expressions
    #
    # @example
    #
    #   strategy = Muster::Strategies::JoinsExpression.new
    #   results  = strategy.parse('joins=author.name,activity')  #=>  { 'joins' => [{'author' => 'name'}, 'activity'] }
    class JoinsExpression < Muster::Strategies::Hash

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
      # @option options [optional,String,RegEx] :field_separator (.) when specified, splits the expression value into multiple field/values
      #  You may pass the separator as a string or a regular expression
      # @option options [optional,Boolean] :unique_values (true) when true, ensures field values do not contain duplicates
      #
      # @example
      #
      #   strategy = Muster::Strategies::FilterExpression.new
      #   strategy = Muster::Strategies::FilterExpression.new(:unique_values => true)
      def initialize( options={} )
        super

        @expression_separator = self.options.fetch(:expression_separator, /,\s*/)
        @field_separator      = self.options.fetch(:field_separator, '.')
        @unique_values        = self.options.fetch(:unique_values, true)
      end

      # Processes a query string and returns an array of hashes that represent an ActiveRecord joins expression
      #
      # @param query_string [String] the query string to parse
      #
      # @return [Muster::Results]
      #
      # @example
      #   
      #   results = strategy.parse('joins=author.name,activity')  #=>  { 'joins' => [{'author' => 'name'}, 'activity'] }
      def parse( query_string )
        parameters = Muster::Results.new( self.fields_to_parse(query_string) )

        parameters.each do |key, value|
          value = value.uniq.first if self.unique_values == true && value.instance_of?(Array)
          parameters[key] = self.make_nested_hash(value)
        end
      end

      protected
      # Converts the array that represents the value to a nested hash
      #
      # @param value [Array] the value to convert
      #
      # @return [String,Array] An array of nested a Hash / Hashes
      #
      # @example
      #
      #   value = self.make_nested_hash('activity,author.country.name')  #=> ['activity', {'author' => {'country' => 'name'}}]
      def make_nested_hash( value )
        expressions = value.split(expression_separator)
        expressions.map do |e| 
          fields = e.split(field_separator)
          fields[0..-2].reverse.reduce(fields.last) { |a, n| { n => a } }
        end
      end

    end
  end
end

