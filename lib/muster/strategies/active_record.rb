require 'active_support/core_ext/array/wrap'
require 'active_support/hash_with_indifferent_access'
require 'muster/strategies/hash'
require 'muster/results'
require 'muster/strategies/filter_expression'
require 'muster/strategies/pagination'
require 'muster/strategies/sort_expression'
require 'muster/strategies/joins_expression'

module Muster
  module Strategies
    # Query string parsing strategy that outputs ActiveRecord Query compatible options
    #
    # @example
    #
    #   strategy = Muster::Strategies::ActiveRecord.new
    #   results  = strategy.parse('select=id,name&where=status:new&order=name:desc')
    #
    #   # { 'select' => ['id', 'name'], :where => {'status' => 'new}, :order => 'name desc' }
    #   #
    #   # Person.select( results[:select] ).where( results[:where] ).order( results[:order] )
    class ActiveRecord < Muster::Strategies::Rack
      # Processes a query string and returns a hash of its fields/values
      #
      # @param query_string [String] the query string to parse
      #
      # @return [Muster::Results]
      #
      # @example
      #
      #   results  = strategy.parse('select=id,name&where=status:new&order=name:desc')
      #
      #   # { 'select' => ['id', 'name'], :where => {'status' => 'new}, :order => 'name desc' }
      def parse(query_string) # rubocop:disable Metrics/MethodLength
        pagination = parse_pagination(query_string)

        parameters = Muster::Results.new(
          :select   => parse_select(query_string),
          :order    => parse_order(query_string),
          :limit    => pagination[:limit],
          :offset   => pagination[:offset],
          :where    => parse_where(query_string),
          :joins    => parse_joins(query_string),
          :includes => parse_includes(query_string)
        )

        parameters.regular_writer('pagination', pagination[:pagination].symbolize_keys)

        parameters
      end

      protected

      # Returns select clauses for AR queries
      #
      # @param query_string [String] the original query string to parse select clauses from
      #
      # @return [Array]
      #
      # @example
      #
      #   value = parse_select('select=id,name')  #=> ['id', 'name']
      def parse_select(query_string)
        strategy = Muster::Strategies::Hash.new(:field => :select)
        results  = strategy.parse(query_string)

        Array.wrap(results[:select])
      end

      # Returns order by clauses for AR queries
      #
      # @param query_string [String] the original query string to parse order clauses from
      #
      # @return [Array]
      #
      # @example
      #
      #   value = parse_order('order=name:desc')  #=> ['name asc']
      def parse_order(query_string)
        strategy = Muster::Strategies::SortExpression.new(:field => :order)
        results  = strategy.parse(query_string)

        Array.wrap(results[:order])
      end

      # Returns pagination information for AR queries
      #
      # @param query_string [String] the original query string to parse pagination from
      #
      # @return [Hash]
      #
      # @example
      #
      #   value = parse_pagination('page=2&page_size=10')  #=> { 'pagination' => {:page => 2, :per_page => 10}, 'limit' => 10, 'offset' => 10 }
      def parse_pagination(query_string)
        strategy = Muster::Strategies::Pagination.new(:fields => [:pagination, :limit, :offset])
        strategy.parse(query_string)
      end

      # Returns where clauses for AR queries
      #
      # - In the case a NULL or NIL query string value is included (case insensitive), a `nil` object is substituted for the String value.
      #
      # @param query_string [String] the original query string to parse where statements from
      #
      # @return [Hash]
      #
      # @example
      #
      #   value = parse_where('where=id:1')  #=> {'id' => '1'}
      #   value = parse_where('where=id:null')  #=> {'id' => nil}
      #   value = parse_where('where=id:nil')  #=> {'id' => nil}
      def parse_where(query_string)
        strategy = Muster::Strategies::FilterExpression.new(:field => :where)
        results  = strategy.parse(query_string)

        nil_regex = /^(null|nil)$/i

        if results[:where] && !results[:where].values.grep(nil_regex).empty?
          results[:where].each do |key, value|
            results[:where][key] = nil if value.match(nil_regex)
          end
        end

        results[:where] || {}
      end

      # Returns joins clauses for AR queries
      #
      # @param query_string [String] the original query string to parse join statements from
      #
      # @return [Hash]
      #
      # @example
      #
      #   value = parse_joins('joins=authors')  #=> {'joins' => 'authors'}
      def parse_joins(query_string)
        strategy = Muster::Strategies::JoinsExpression.new(:field => :joins)
        results  = strategy.parse(query_string)

        results[:joins] || {}
      end

      # Returns includes clauses for AR queries
      #
      # @param query_string [String] the original query string to parse join statements from
      #
      # @return [Hash]
      #
      # @example
      #
      #   value = parse_joins('includes=authors')  #=> {'includes' => 'authors'}
      def parse_includes(query_string)
        strategy = Muster::Strategies::JoinsExpression.new(:field => :includes)
        results  = strategy.parse(query_string)

        results[:includes] || {}
      end
    end
  end
end
