require_relative 'notifier'

module Uvobot
  module Notifications
    class DiscourseNotifier < Notifier
      def initialize(discourse_client, category, scraper)
        @client = discourse_client
        @category = category
        @scraper = scraper
      end

      def no_announcements_found
        # noop
      end

      def new_issue_not_published
        # noop
      end

      def matching_announcements_found(_page_info, announcements)
        announcements.each do |a|
          topic = announcement_to_topic(a)
          @client.store_topic(order_id: a[:order][:id], topic: topic, category: @category)
        end
      end

      private

      def announcement_to_topic(announcement)
        details = @scraper.get_announcement_detail(announcement[:link][:href], announcement[:release_date])
        response = {}
        response[:title] = announcement[:procurement_subject].to_s
        response[:body] = [
            "**Obstarávateľ:** #{announcement[:procurer]}",
            "**Predmet obstarávania:** #{announcement[:procurement_subject]}",
            price_details(details),
            order_documents(details),
            "**Zdroj:** [#{announcement[:link][:text]}](#{announcement[:link][:href]})"
        ].join("  \n")
      end

      def price_details(details)
        if details && details[:amount]
          "**Cena:** #{details[:amount]}"
        else
          '**Cena:** nepodarilo sa extrahovať'
        end
      end

      def order_documents(details)
        if details && details[:order] && details[:order][:documents]
          response = [ "** Dokumenty zákazky:**" ]
          details[:order][:documents].each do |document|
            response << "#{document[:name]} [#{document[:href]}]"
          end
          response.join("  \n")
        else
          '** Dokumenty zákazky:** nepodarilo sa extrahovať.**'
        end
      end
    end
  end
end
