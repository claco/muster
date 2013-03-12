require 'muster/strategies/hash'

module Muster
  module Strategies

    class JoinsExpression < Muster::Strategies::Hash
      attr_reader :expression_separator
      attr_reader :field_separator
      attr_reader :unique_values

      def initialize( options={} )
        super

        @expression_separator = self.options.fetch(:expression_separator, /,\s*/)
        @field_separator      = self.options.fetch(:field_separator, '.')
        @unique_values        = self.options.fetch(:unique_values, true)
      end

      def parse( query_string )
        parameters = Muster::Results.new( self.fields_to_parse(query_string) )


        parameters.each do |key, value|
          value = value.uniq.first if unique_values == true && value.instance_of?(Array)
          parameters[key] = self.make_nested_hash(value)
        end
      end

      protected

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

