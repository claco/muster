require 'active_support/core_ext/hash/slice'
require 'muster/results'
require 'muster/strategies/hash'

module Muster
  module Strategies
    # Query string parsing strategy with logic to handle pagination options
    #
    # @example
    #
    #   strategy = Muster::Strategies::Pagination.new
    #   results  = strategy.parse('page=3&per_page=10')  #=>  { 'pagination' => {'page' => 3, 'per_page' => 10}, 'limit' => 10, 'offset' => 20 }
    class Pagination < Muster::Strategies::Rack
      # @attribute [r] default_page_size
      # @return [Fixnum] when specified, will override the default page size of 30 when no page_size is parsed
      attr_accessor :default_page_size

      # Create a new Pagination parsing strategy
      #
      # @param [Hash] options the options available for this method
      # @option options [optional,Array<Symbol>] :fields when specified, only parse the specified fields
      #  You may also use :field if you only intend to pass one field
      # @option options [optional,String,RegEx] :value_separator (/,\s*/) when specified, splits the field value into multiple values
      #  You may pass the separator as a string or a regular expression
      # @option options [optional,Boolean] :unique_values (true) when true, ensures field values do not contain duplicates
      # @option options [options,Fixnum] :default_page_size (30) when specified, the default page size to use when no page size is parsed
      #
      # @example
      #
      #   strategy = Muster::Strategies::Pagination.new
      #   strategy = Muster::Strategies::Pagination.new(:default_page_size => 10)
      def initialize(options = {})
        super

        self.default_page_size = options[:default_page_size].to_i

        return unless default_page_size < 3

        self.default_page_size = 30
      end

      # Processes a query string and returns a hash of its fields/values
      #
      # @param query_string [String] the query string to parse
      #
      # @return [Muster::Results]
      #
      # @example
      #
      #   results = strategy.parse('page=3&per_page=10')  #=>  { 'pagination' => {'page' => 3, 'per_page' => 10}, 'limit' => 10, 'offset' => 20 }
      def parse(query_string)
        parameters = parse_query_string(query_string)

        page = parse_page(parameters)
        page_size = parse_page_size(parameters)

        offset = (page - 1) * page_size
        offset = nil if offset < 1

        parameters = parameters.merge(:pagination => { :page => page, :per_page => page_size }, :limit => page_size, :offset => offset)

        if fields.present?
          parameters = parameters.slice(*fields)
        end

        Muster::Results.new(parameters)
      end

      protected

      # Returns the current page for the current query string.
      #
      # If page is not specified, or is not a positive number, 1 will be returned instead.
      #
      # @param parameters [Hash] the parameters parsed from the query string
      #
      # @return [Fixnum]
      #
      # @example
      #
      #   page = parse_page(:page => 2)    #=>  2
      #   page = parse_page(:page => nil)  #=>  1
      def parse_page(parameters)
        page = parameters.delete(:page).to_i
        page = 1 unless page > 0
        page
      end

      # Returns the page size for the current query string.
      #
      # If per_page or page_size is not specified, or is not a positive number, :default_page_size will be returned instead.
      #
      # @param parameters [Hash] the parameters parsed from the query string
      #
      # @return [Fixnum]
      #
      # @example
      #
      #   page_size = parse_page(:page_size => 10)  #=>  10
      #   page_size = parse_page(:per_page  => 10)  #=>  10
      #   page_size = parse_page(:per_page  => nil) #=>  30
      def parse_page_size(parameters)
        page_size = (parameters.delete(:page_size) || parameters.delete(:per_page)).to_i
        page_size = default_page_size unless page_size > 0
        page_size
      end
    end
  end
end
