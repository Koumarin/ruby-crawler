#!/usr/bin/env ruby
require 'net/http'
require 'nokogiri'
require 'optparse'

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

  visited.push uri

  html = Net::HTTP.get uri
  doc  = Nokogiri::HTML html
  (doc.xpath '//a').each do |link|
    puts link['href']
  end
end
