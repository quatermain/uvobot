module Uvobot::Store
  class CreateTopicsTable < ::ActiveRecord::Migration

    def up
      create_table :topics do |t|
        t.string :order_id
        t.string :topic_id
      end
      add_index :topics, :order_id
    end

    def down
      drop_table :topics
    end
  end
end