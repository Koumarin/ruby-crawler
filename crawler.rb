#!/usr/bin/env ruby
require 'open-uri'
require 'optparse'

require 'nokogiri'

def links_from_doc(doc)
  (doc.xpath '//a')                     # We catch all anchors,
    .map {|link| link['href']}          # extract all hrefs from it and then
    .filter {|str| str}                 # remove empty links.
end

DATA_DIR = 'crawled'
Dir.mkdir DATA_DIR unless File.exists? DATA_DIR

parser = OptionParser.new

args = parser.parse!

if args.length < 1
  puts 'Please provide at least one URI to start crawling.'
  exit
end

unvisited = args.map {|src| URI src}
visited   = []

while unvisited.length > 0
  uri        = unvisited.pop
  local_file = "#{DATA_DIR}/#{File.basename uri.to_s}.html"

  visited.push uri

  next if File.exists? local_file       # Skip things we have already seen.

  puts "Visiting #{uri}"

  html = uri.open 'User-Agent' => "Ruby/#{RUBY_VERSION}"
  doc  = Nokogiri::HTML5 html, uri

  File.open(local_file, 'w') {|file| file.write html}
  puts "Saved: #{local_file}"

  (links_from_doc doc).each do |link|
    new_uri = URI link

    if new_uri.scheme == nil
      new_uri = (URI uri.origin).merge link
    end

    ## We skip non-HTTP protocols.
    next unless ['http', 'https'].include? new_uri.scheme

    ## If we haven't seen the link yet, we save it to crawl later.
    unless (visited + unvisited).include? new_uri
      unvisited.push new_uri
    end
  end

  sleep 1                               # We avoid making too many requests.
end
