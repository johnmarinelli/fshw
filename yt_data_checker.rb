module YoutubeDataChecker
  # represents a more user friendly format of a CSV file
  class ParsedCsv
    attr_accessor :headers, :data
    def init(arr)
      # tokenize headers 
      @headers = arr[0].map { |h| h.strip.downcase.sub(' ', '_').to_sym }

      # turn all rows into processing friendly format
      @data = arr[1..arr.count].map do |d|
        Hash[@headers.collect.with_index { |header, idx| [header, d[idx]] }]
      end
    end
  end
end
