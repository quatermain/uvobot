require 'active_record'
require_relative 'create_topics_table'
require_relative 'topic'

module Uvobot
  module Store
    class Manager
      def initialize(database_url)
        ActiveRecord::Base.establish_connection(database_url)
        check_migration
      end

      def check_topic?(order_id)
        Topic.where(order_id: order_id).count > 0
      end

      def get_topic_id(order_id)
        Topic.where(order_id: order_id).first.topic_id
      end

      def check_migration
        unless ActiveRecord::Base.connection.table_exists? 'topics'
          run_migration
        end
      end

      private

      def run_migration
        CreateTopicsTable.migrate(:up)
      end
    end
  end
end