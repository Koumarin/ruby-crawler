#!/usr/bin/env ruby
require 'net/http'
require 'optparse'

parser = OptionParser.new

args = parser.parse!

if args.length != 1
  puts 'Wrong number of arguments.'
  exit
end

path = args.first

puts Net::HTTP.get URI path
