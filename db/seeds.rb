# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

#create initial 3k lockers
Locker::LOCKER_SIZES.each do |sz| 
  1000.times do 
    key = sz + ':' + SecureRandom.urlsafe_base64
    $redis.hset(sz,key,false)
  end
end