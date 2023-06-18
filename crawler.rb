#!/usr/bin/env ruby
require 'net/http'
require 'nokogiri'
require 'optparse'

def links_from_html(html)
  doc = Nokogiri::HTML html
  (doc.xpath '//a').map {|link| href = link['href']}
end

parser = OptionParser.new

args = parser.parse!

if args.length < 1
  puts 'Please provide at least one URI to start crawling.'
  exit
end

unvisited = args.map {|src| URI src}
visited   = []

while unvisited.length > 0
  uri = unvisited.pop

  puts "Visiting #{uri}"

  visited.push uri

  html = Net::HTTP.get uri

  (links_from_html html).each do |link|
    next if not link.start_with? '/'   # Skip non-root based links for now.

    new_uri = URI link

    if not new_uri.kind_of? URI::HTTP
      new_uri = URI uri.origin + link
    end

    if not (visited + unvisited).include? new_uri
      unvisited.push new_uri
    end
  end
end
