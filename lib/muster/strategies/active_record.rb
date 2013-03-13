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
      def parse( query_string )
        pagination = self.parse_pagination( query_string )

        parameters = Muster::Results.new(
          :select   => self.parse_select(query_string),
          :order    => self.parse_order(query_string),
          :limit    => pagination[:limit],
          :offset   => pagination[:offset],
          :where    => self.parse_where(query_string),
          :joins    => self.parse_joins(query_string),
          :includes => self.parse_joins(query_string)
        )

        parameters.regular_writer('pagination', pagination[:pagination].symbolize_keys)

        return parameters
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
      #   value = self.parse_select('select=id,name')  #=> ['id', 'name']
      def parse_select( query_string )
        strategy = Muster::Strategies::Hash.new(:field => :select)
        results  = strategy.parse(query_string)

        return Array.wrap( results[:select] )
      end

      # Returns order by clauses for AR queries
      #
      # @param query_string [String] the original query string to parse order clauses from
      #
      # @return [Array]
      #
      # @example
      #
      #   value = self.parse_order('order=name:desc')  #=> ['name asc']
      def parse_order( query_string )
        strategy = Muster::Strategies::SortExpression.new(:field => :order)
        results  = strategy.parse(query_string)

        return Array.wrap( results[:order] )
      end

      # Returns pagination information for AR queries
      #
      # @param query_string [String] the original query string to parse pagination from
      #
      # @return [Hash]
      #
      # @example
      #
      #   value = self.parse_pagination('page=2&page_size=10')  #=> { 'pagination' => {:page => 2, :per_page => 10}, 'limit' => 10, 'offset' => 10 }
      def parse_pagination( query_string )
        strategy = Muster::Strategies::Pagination.new(:fields => [:pagination, :limit, :offset])
        results  = strategy.parse(query_string)
        
        return results
      end

      # Returns where clauses for AR queries
      #
      # @param query_string [String] the original query string to parse where statements from
      #
      # @return [Hash]
      #
      # @example
      #
      #   value = self.parse_where('where=id:1')  #=> {'id' => '1'}
      def parse_where( query_string )
        strategy = Muster::Strategies::FilterExpression.new(:field => :where)
        results  = strategy.parse(query_string)

        return results[:where] || {}
      end

      # Returns joins clauses for AR queries
      #
      # @param query_string [String] the original query string to parse join statements from
      #
      # @return [Hash]
      #
      # @example
      #
      #   value = self.parse_joins('joins=authors')  #=> {'joins' => 'authors'}
      def parse_joins( query_string )
        strategy = Muster::Strategies::JoinsExpression.new(:field => :joins)
        results  = strategy.parse(query_string)

        return results[:joins] || {}
      end

    end
  end
end
