Dir[File.dirname(__FILE__) + '/data_checker/*.rb'].each do |f|
  require f
end
