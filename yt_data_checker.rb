require 'csv'
require_relative 'lib/data_checker.rb'

path1, path2, concern = ARGV[0], ARGV[1], ARGV[2] || :none

class InvalidPathException < Exception
end

class InvalidConcernException < Exception
end

raise InvalidPathException if not (File.exists? path1 and File.exists? path2)
raise InvalidConcernException if not (concern == 'subscriber_count' or concern == 'channel_ownership' or concern.nil?)

csv1 = CSV.read path1
csv2 = CSV.read path2
pc1 = YoutubeDataChecker::ParsedCsv.new csv1
pc2 = YoutubeDataChecker::ParsedCsv.new csv2
discrepancy_finder = YoutubeDataChecker::DiscrepancyFinder.new concern.to_sym
discs = discrepancy_finder.find_discrepancies pc1, pc2

printf discs.join
