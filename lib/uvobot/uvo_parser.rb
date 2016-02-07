require 'nokogiri'

module Uvobot
  class UvoParser
    def self.parse_announcements(html, bulletin_url, release_date)
      announcements = []

      doc(html).css('#lists-table tr[onclick]').each do |tr|
        announcements << parse_table_line(tr, bulletin_url, release_date)
      end
      announcements
    end

    def self.parse_table_line(tr_node, bulletin_url, release_date)
      a_parts = tr_node.css('td').first.text.split("\n").map(&:strip)

      {
        release_date: release_date,
        link: { text: a_parts[0], href: parse_detail_link(tr_node, bulletin_url) },
        procurer: a_parts[1],
        procurement_subject: a_parts[2]
      }
    end

    def self.parse_order_documents_url(announcement_html)
      url = doc(announcement_html).css('#procurer table tr:first td a').first['href']
      [
          url.split('/').last,
          url.gsub('zdetail','zdokumenty')+ '?_profilObstaravatela_WAR_uvoprofil_sortKey=datum_dt&_profilObstaravatela_WAR_uvoprofil_sortOrder=desc'
      ]
    end

    def self.parse_order_documents(document_html, bulletin_url, release_date)
      documents = []
      doc(document_html).css('.obst_search_container .reg_search:first tbody tr').each do |row|
        td, td_date = row.css('td')
        if release_date == Date.parse(td_date.text.strip)
          document = {}
          document[:name] = td.text
          document[:href] = bulletin_url + td.css('a').first['href']
          documents << document
        end
      end
      documents
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
