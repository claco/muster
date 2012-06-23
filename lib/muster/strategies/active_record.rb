require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/array/wrap'
require 'active_support/hash_with_indifferent_access'
require 'muster/strategies/hash'
require 'muster/strategies/filter_expression'
require 'muster/strategies/pagination'
require 'muster/strategies/sort_expression'

module Muster
  module Strategies
    class ActiveRecord

      # base
      def initialize( options={} )

      end

      def parse( query_string )
        # move force array up into base options along with generic value split
        # split these into methods
        selects = Muster::Strategies::Hash.new(:only => :select, :csv => true).parse(query_string)
        selects[:select] = Array.wrap(selects[:select])

        orders = Muster::Strategies::SortExpression.new(:only => :order).parse(query_string)
        orders[:order] = Array.wrap(orders[:order])

        pagination = Muster::Strategies::Pagination.new(:only => [:pagination, :limit, :offset]).parse(query_string)

        wheres = Muster::Strategies::FilterExpression.new(:only => :where).parse(query_string)

        parameters = ActiveSupport::HashWithIndifferentAccess.new(
          :select => selects[:select],
          :order  => orders[:order],
          :limit  => pagination[:limit],
          :offset => pagination[:offset],
          :where  => wheres[:where] || {}
        )

        parameters.regular_writer('pagination', pagination[:pagination].symbolize_keys)

        return parameters
      end

    end
  end
end
