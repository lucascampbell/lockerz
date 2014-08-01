if Rails.env == 'production'
  #link to prod redis 
else
  $redis = Redis.new(:host => 'localhost', :port => 6379)
end

