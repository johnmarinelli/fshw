module YoutubeDataChecker
  # represents a more user friendly format of a CSV file
  class ParsedCsv
    attr_reader :headers, :data

    # assumes arr[0] is headers, and the rest are valid csv rows
    def initialize(arr)
      # tokenize headers 
      @headers = arr[0].map { |h| h.strip.downcase.sub(' ', '_').to_sym }

      # turn all rows into processing friendly format
      @data = arr[1..arr.count].map do |d|
        Hash[@headers.collect.with_index { |header, idx| [header, d[idx]] }]
      end
    end

    private
    attr_writer :headers, :data
  end

  # finds discrepancies between two ParsedCsvs.
  class DiscrepancyFinder
    attr_reader :discrepancies
    attr_accessor :concern

    def initialize(concern = :none)
      @concern = concern 
    end

    # a, b are ParsedCsv objects
    # returns an array of objects, each describing a discrepancy
    def find_discrepancies(csv1, csv2)
      @discrepancies = []

      csv1.data.each_with_index do |d, idx|
        @discrepancies << get_discrepancies(d, csv2.data[idx], idx)
      end
      @discrepancies.compact!
    end

    private
    attr_writer :discrepancies

    def email_difference?(a, b)
      a[:account_email] != b[:account_email]
    end

    def subs_count_difference?(a, b)
      Integer(a[:subscriber_count].gsub ',', '') != Integer(b[:subscriber_count].gsub ',', '')
    end

    def channel_owner_difference?(a, b)
      # returns a youtube id given various formats
      get_id = lambda { |s| s = s.split('/').last; if s[0..1] == 'UC'then s[2..s.length] else s end; }
      get_id.call(a[:youtube_channel]) != get_id.call(b[:youtube_channel])
    end

    def different?(a, b)
      if @concern == :subscriber_count
        subs_count_difference?(a, b)
      elsif @concern == :channel_ownership
        channel_owner_difference?(a, b)
      else
        email_difference?(a,b) or subs_count_difference?(a,b) or channel_owner_difference?(a,b)
      end
    end

    def same?(a, b)
      !different?(a, b)
    end
    
    # return object describing a discrepancy, or nil if there are no discrepancies
    def get_discrepancies(a, b, idx)
      disc_info = ''
      if same?(a, b)
        nil
      else
        row_info = "at row #{idx + 1}\n"
        if @concern == :subscriber_count
          disc_info = "#{a[:subscriber_count]} != #{b[:subscriber_count]} #{row_info}"
        elsif @concern == :channel_ownership
          disc_info = "#{a[:youtube_channel]} != #{b[:youtube_channel]} #{row_info}"
        else
          disc_info = "#{a[:account_email]} has discrepancy #{row_info}"
        end
        disc_info
      end
    end
  end
end
