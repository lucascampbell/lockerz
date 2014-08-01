require 'spec_helper'

describe "Locker", "Get Set reservations" do
  before(:each) do
    Locker::LOCKER_SIZES.each{|sz|$redis.del(sz)}
    Locker::LOCKER_SIZES.each do |sz| 
      1000.times do 
        key = sz + ':' + SecureRandom.urlsafe_base64
        $redis.hset(sz,key,false)
      end
    end
  end
  it "should have locer sizes loaded" do 
     expect(Locker::LOCKER_SIZES).to match_array(["SM","MD","LG"])
  end
  
  it "should return key of reservation" do
    key = Locker.reserve('SM')
    puts "key is #{key}"
    expect(key).not_to be_empty
    expect(key.size).to eq(25)
  end

  it "should insert into SM buckets" do
    key1 = Locker.reserve('SM')
    key2 = $redis.hget("SM",key1)
    expect(key2).to eq('true')

    Locker.checkout(key1)
    key2 = $redis.hget("SM",key1)
    expect(key2).to eq('false')
  end

  it "should insert into MD buckets" do
    key1 = Locker.reserve('MD')
    key2 = $redis.hget("MD",key1)
    expect(key2).to eq('true')

    Locker.checkout(key1)
    key2 = $redis.hget("MD",key1)
    expect(key2).to eq('false')
  end

  it "should insert into LG buckets" do
    key1 = Locker.reserve('LG')
    key2 = $redis.hget("LG",key1)
    expect(key2).to eq('true')

    Locker.checkout(key1)
    key2 = $redis.hget("LG",key1)
    expect(key2).to eq('false')
  end

  it "should return false if bag not found" do
    key = Locker.checkout('SM:wrongkey')
    expect(key).to eq(false)
  end
  
  #test takes a while, might want to use subset of total reservations
  it "should use MD if SM is full" do 
    1000.times{|i| Locker.reserve('SM')}

    key = Locker.reserve('SM')
    expect(key.split(":")[0]).to eq("MD")

    sm_key = $redis.hgetall('SM').detect{|key,value| value=='false'}
    expect(sm_key).to be_nil
  end

  #test takes a while, might want to use subset of total reservations
  it "should use MD if SM is full" do 
    1000.times{|i| Locker.reserve('SM')}
    1000.times{|i| Locker.reserve('MD')}

    key = Locker.reserve('MD')
    expect(key.split(":")[0]).to eq("LG")

    sm_key = $redis.hgetall('MD').detect{|key,value| value=='false'}
    expect(sm_key).to be_nil
  end

  #test takes a while, might want to use subset of total reservations
  it "should use MD if SM is full" do 
    1000.times{|i| Locker.reserve('SM')}
    1000.times{|i| Locker.reserve('MD')}
    1000.times{|i| Locker.reserve('LG')}

    key = Locker.reserve('LG')
    expect(key).to eq(false)

    sm_key = $redis.hgetall('LG').detect{|key,value| value=='false'}
    expect(sm_key).to be_nil
  end



end