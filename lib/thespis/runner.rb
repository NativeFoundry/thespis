require 'net/http'
require 'uri'
require 'open-uri'
require 'nokogiri'
require 'cgi'
require 'byebug'

module Thespis
  class Runner
    def self.greet
      "Hello"
    end

    def self.search(states)
      parsed_states = parse_states(states)

      listings = parsed_states.map do |state|
        fetch_playbill(state)
      end

      listings.flatten

      # Could do deeper searching, but the data isn't regular in how it's divided on the page.
      listings.flatten.map do |listing|

        # Request listing-specific data
        uri = URI.parse(listing[:url])
        response_body = Net::HTTP.get_response(uri).body
        html_doc = Nokogiri::HTML(response_body)

        # Parse data for specific chunks
        company = html_doc.css(".jobs-section").children[1].children[0].text.strip
        audition_type = html_doc.css(".jobs-section")[1].children[4].children[1].text.strip
        contract = html_doc.css(".jobs-section")[1].children[4].children[6].text.strip
        # where = html_doc.css(".jobs-section")[2].children[4].text.strip # This might want additional parsing for address etc
        # to_prepare = html_doc.css(".jobs-section")[2].children[6].text.strip

        # Return object w/ all the chunks
        {
          source: listing[:source],
          title: listing[:title],
          company: company,
          # where: where,
          # to_prepare: to_prepare,
          url: listing[:url],
          state: listing[:state]
        }
      end
    end

    def self.fetch_playbill(state)
      uri = URI.parse("http://www.playbill.com/job/listing")
      uri.query = "q=&category=Performer&date=&state=#{state}&paid=on"
      body = Net::HTTP.get_response(uri).body
      html_doc = Nokogiri::HTML(body)

      parsed_listings = []

      listings = html_doc.css("div.pb-tile-wrapper")

      listings.each do |listing|

        title = listing.children[1].css("div.pb-tile-title").children[0].to_s.strip
        listing_url = listing.css('a')[0]['href']
        url = "http://www.playbill.com#{listing_url}"

        parsed_listings << {
          source: "Playbill",
          title: title,
          url: url,
          state: state
        }
      end

      return parsed_listings
    end

    def self.fetch_listing(listing)
      debugger
    end


    def self.parse_states(states)
      if states.class == String
        states.split(", ")
      elsif states.class == Array
        states
      else
        puts "States not valid"
      end
    end
  end
end
