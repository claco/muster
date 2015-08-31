require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/array/wrap'
require 'muster/strategies/rack'

module Muster
  module Strategies
    # Query string parsing strategy with additional value handling options for separating values and uniqueness
    #
    # @example
    #
    #   strategy = Muster::Strategies::Hash.new(:unique_values => true, :value_separator => ',')
    #   results  = strategy.parse('name=value&choices=1,2,1')  #=>  { 'name' => 'value', 'choices' => ['1', '2'] }
    class Hash < Muster::Strategies::Rack
      # @attribute [r] value_separator
      # @return [String,RegEx] when specified, each field value will be split into multiple values using the specified separator
      attr_reader :value_separator

      # @attribute [r] unique_values
      # @return [Boolean] when specified, ensures a fields values do not contain duplicates
      attr_reader :unique_values

      # Create a new Hash parsing strategy
      #
      # @param [Hash] options the options available for this method
      # @option options [optional,Array<Symbol>] :fields when specified, only parse the specified fields
      #  You may also use :field if you only intend to pass one field
      # @option options [optional,String,RegEx] :value_separator (/,\s*/) when specified, splits the field value into multiple values
      #  You may pass the separator as a string or a regular expression
      # @option options [optional,Boolean] :unique_values (true) when true, ensures field values do not contain duplicates
      #
      # @example
      #
      #   strategy = Muster::Strategies::Hash.new(:fields => [:name, :state], :value_separator => '|')
      #   strategy = Muster::Strategies::Hash.new(:unique_values => false)
      def initialize(options = {})
        super

        @unique_values   = self.options.fetch(:unique_values, true)
        @value_separator = self.options.fetch(:value_separator, /,\s*/)
      end

      # Processes a query string and returns a hash of its fields/values
      #
      # @param query_string [String] the query string to parse
      #
      # @return [Muster::Results]
      #
      # @example
      #
      #   results = strategy.parse('name=value&choices=1,2')  #=>  { 'name' => 'value', 'choices' => ['1', '2'] }
      def parse(query_string)
        parameters = super

        parameters.each do |key, value|
          if value_separator.present?
            parameters[key] = separate_values(value)
          end

          if unique_values == true && value.instance_of?(Array)
            parameters[key].uniq!
          end
        end

        parameters
      end

      protected

      # Separates values into an Array of values using :values_separator
      #
      # @param values_string [String,Array] the original query string field value to separate
      #
      # @return [String,Array] String if a single value exists, Array otherwise
      #
      # @example
      #
      #   value = self.separate_values('1')    #=> '1'
      #   value = self.separate_values('1,2')  #=>  ['1', '2']
      def separate_values(values_string)
        values = Array.wrap(values_string)

        values = values.map do |value|
          value.split(value_separator)
        end.flatten

        (values.size > 1) ? values : values_string
      end
    end
  end
end
