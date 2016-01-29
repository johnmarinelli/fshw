require 'csv'

describe 'youtube data integrity checker' do
  def parsed_csv(arr)
    YoutubeDataChecker::ParsedCsv.new arr
  end

  def discrepancy_finder(concern = :none)
    YoutubeDataChecker::DiscrepancyFinder.new concern
  end

  def get_csv_arr(filename)
    CSV.read File.dirname(__FILE__) + "/../../csv/#{filename}"
  end

  it 'has correct headers' do
    arr = get_csv_arr 'file1_test.csv'
    pc = parsed_csv arr
    expect(pc.headers).to eq([:account_email, :youtube_channel, :subscriber_count])
  end

  it 'shows no discrepancancies between two identical files' do
    arr = get_csv_arr 'file1_test.csv'
    arr2 = get_csv_arr 'file1_test.csv'
    pc = parsed_csv arr
    pc2 = parsed_csv arr2
    
    df = discrepancy_finder
    ds = df.find_discrepancies pc, pc2
    expect(ds.count).to eq(0)
  end

  it 'shows discrepancies between two files without a concern' do
    arr = get_csv_arr 'file1_test.csv'
    arr2 = get_csv_arr 'file2_test.csv'
    pc = parsed_csv arr
    pc2 = parsed_csv arr2
    
    ds = discrepancy_finder.find_discrepancies pc, pc2
    expect(ds.count).to eq(1)
    expect(ds[0]).to include("person_2@gmail.com")
  end

  it 'shows discrepancies between two files with a channel ownership concern' do
    arr = get_csv_arr 'file1_test.csv'
    arr2 = get_csv_arr 'file2_test.csv'
    pc = parsed_csv arr
    pc2 = parsed_csv arr2
    
    ds = discrepancy_finder.find_discrepancies pc, pc2
    expect(ds.count).to eq(1)
    expect(ds[0]).to include("person_2@gmail.com")
  end

  it 'shows no discrepancies between two files with a channel ownership concern' do
    arr = get_csv_arr 'file2_test.csv'
    arr2 = get_csv_arr 'file3_test.csv'
    pc = parsed_csv arr
    pc2 = parsed_csv arr2
    
    ds = discrepancy_finder(:channel_ownership).find_discrepancies pc, pc2
    expect(ds.count).to eq(0)
  end

  it 'shows no discrepancies between two files with a channel ownership concern and an optional UC in yt id' do
    arr = get_csv_arr 'file4_test.csv'
    arr2 = get_csv_arr 'file3_test.csv'
    pc = parsed_csv arr
    pc2 = parsed_csv arr2
    
    ds = discrepancy_finder(:channel_ownership).find_discrepancies pc, pc2
    expect(ds.count).to eq(0)
  end

  it 'shows discrepancies between two files with a subscriber count concern' do
    arr = get_csv_arr 'file1_test.csv'
    arr2 = get_csv_arr 'file3_test.csv'
    pc = parsed_csv arr
    pc2 = parsed_csv arr2
    
    ds = discrepancy_finder(:subscriber_count).find_discrepancies pc, pc2
    expect(ds.count).to eq(1)
    expect(ds[0]).to include("row 1")
  end

  it 'shows no discrepancies between two files with a subscriber count concern' do
    arr = get_csv_arr 'file1_test.csv'
    arr2 = get_csv_arr 'file2_test.csv'
    pc = parsed_csv arr
    pc2 = parsed_csv arr2
    
    ds = discrepancy_finder(:subscriber_count).find_discrepancies pc, pc2
    expect(ds.count).to eq(0)
  end
end
