require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/array/wrap'
require 'rack/utils'
require 'muster/results'

module Muster
  module Strategies

    # Query string parsing strategy based on Rack::Utils#parse_query
    #
    # @example
    #
    #   strategy = Muster::Strategies::Rack.new
    #   results  = strategy.parse('name=value&choices=1&choices=2')  #=>  { 'name' => 'value', 'choices' => ['1', '2'] }
    class Rack

      # @attribute [r] options
      # @return [Hash] options specified during initialization
      attr_reader :options

      # @attribute [r] fields
      # @return [Hash] list of fields to parse, ignoring all others
      attr_reader :fields

      # Create a new Rack parsing strategy
      #
      # @param [Hash] options the options available for this method
      # @option options [optional,Array<Symbol>] :fields when specified, only parse the specified fields
      #  You may also use :field if you only intend to pass one field
      #
      # @example
      #
      #   strategy = Muster::Strategies::Rack.new(:fields => [:name, :state])
      #   strategy = Muster::Strategies::Rack.new(:field  => :name)
      def initialize( options={} )
        @options = options.with_indifferent_access

        @fields  = Array.wrap(@options[:field] || @options[:fields])
        @fields.map!{ |field| field.to_sym }
      end

      # Processes a query string and returns a hash of its fields/values
      #
      # @param query_string [String] the query string to parse
      #
      # @return [Muster::Results]
      #
      # @example
      #   
      #   results = strategy.parse('name=value&choices=1&choices=1')  #=>  { 'name' => 'value', 'choices' => ['1', '2'] }
      def parse( query_string )
        Muster::Results.new( self.fields_to_parse(query_string) )
      end

      protected

      # Converts the query string into a hash for processing
      #
      # @param query_string [String] the query string being parsed
      #
      # @return [Hash]
      #
      # @example
      #
      #   fields = self.parse_query_string('name=value&choices=1&choices=1')  #=>  { 'name' => 'value', 'choices' => ['1', '2'] }
      def parse_query_string( query_string )
        ::Rack::Utils.parse_query(query_string).with_indifferent_access
      end

      # Returns the list of fields to be parsed
      #
      # @param query_string [String] the query string to parse
      #
      # If the :fields option was specified, only those fields will be returned. Otherwise, all fields will be returned.
      #
      # @return [Hash]
      def fields_to_parse( query_string )
        fields = self.parse_query_string(query_string)

        if self.fields.present?
          fields = fields.select{ |key, value| self.fields.include?(key.to_sym) }
        end

        return fields.with_indifferent_access
      end

    end
  end
end
