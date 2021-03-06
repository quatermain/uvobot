require 'nokogiri'

module Uvobot
  class UvoParser
    def self.parse_announcements(html, bulletin_url)
      announcements = []

      doc(html).css('#lists-table tr[onclick]').each do |tr|
        announcements << parse_table_line(tr, bulletin_url)
      end
      announcements
    end

    def self.parse_table_line(tr_node, bulletin_url)
      a_parts = tr_node.css('td').first.text.split("\n").map(&:strip)

      {
        link: { text: a_parts[0], href: parse_detail_link(tr_node, bulletin_url) },
        procurer: a_parts[1],
        procurement_subject: a_parts[2]
      }
    end

    def self.parse_detail_link(tr_node, bulletin_url)
      bulletin_url + tr_node.attributes['onclick'].text.scan(/'(.*)'/).first[0]
    end

    def self.parse_detail(html)
      # there are multiple formats of detail page, this method does not handle them all for now
      h_doc = doc(html)
      amount_nodes = h_doc.xpath('//div[text()="Hodnota            "]')
      return nil if amount_nodes.count == 0

      first_amount = amount_nodes.first.css('span').map { |s| s.text.strip }.join(' ')

      { amount: first_amount }
    end

    def self.parse_page_info(html)
      page_info_node = doc(html).css('div.pag-info span').first
      page_info_node.nil? ? nil : page_info_node.text.strip
    end

    def self.parse_issue_header(html)
      doc(html).css('h1').text
    end

    def self.doc(html)
      Nokogiri::HTML(html)
    end
  end
end
