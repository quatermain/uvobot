require 'discourse_api'

module Uvobot
  class DiscourseClient
    def initialize(host: nil, api_key: nil, api_username: nil, local_store: nil)
      @client = DiscourseApi::Client.new(host, api_key, api_username)
      @local_store = local_store
    end

    def store_topic(order_id: nil, topic: nil, category: nil)
      if @local_store.check_topic?(order_id)
        create_post(@local_store.get_topic_id(order_id), topic[:body])
      else
        response = create_topic(
            title: topic[:title],
            raw: topic[:body],
            category: category
        )
        # TODO: get topic_id and store it
      end
    end

    def create_topic(args = {})
      @client.create_topic(args)
    rescue DiscourseApi::Error
      return nil
    end

    def create_post(topic_id, content)
      @client.create_post(topic_id: topic_id, raw: content)
    rescue DiscourseApi::Error
      return nil
    end
  end
end
