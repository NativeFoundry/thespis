require 'net/http'
require 'uri'
require 'open-uri'
require 'nokogiri'
require 'cgi'


module Thespis
  class Runner
    def self.greet
      "Hello"
    end

    def self.pull_playbill(states)
      notices = []
      states = parse_states(states)
      states.each do |state|
        uri = URI.parse("http://www.playbill.com/job/listing")
        uri.query = "q=&category=Performer&date=&state=#{state}&paid=on"
        body = Net::HTTP.get_response(uri).body
        html_doc = Nokogiri::HTML(body)
        html_doc.css("table.bsp-table tr").each do |listing|
          title = "Playbill - #{listing.children[1].css("a span").text}"
          listing_url = listing.children[1].css("a")[0]['href']
          link = "http://www.playbill.com#{listing_url}"
          details = pull_details(listing_url)
          notices << { title: title, link: link, details: details }
        end
      end
      notices
    end

    private

    def self.parse_states(states)
      if states.class == String
        states.split(", ")
      elsif states.class == Array
        states
      else
        puts "States not valid"
      end
    end

    def self.pull_details(listing_url)
      uri = URI.parse("http://www.playbill.com#{listing_url}")
      body = Net::HTTP.get_response(uri).body
      html_doc = Nokogiri::HTML(body)

      company_info = html_doc.css("section.jobs-section")[0].text
      details = html_doc.css("section.jobs-section")[1].children.to_s
      { company: company_info, details: details }
    end
  end
end