class Locker
  LOCKER_SIZES = ["SM","MD","LG"]

  def self.reserve(size)
    if key = next_bucket(size)
      $redis.hset(size,key,true)
    else
      key = false
    end
    key
  end

  def self.checkout(key)
    if $redis.hget(key.split(':')[0],key)
      $redis.hset(key.split(':')[0],key,false)
    else
      false
    end
  end

  private

  #check sets for next size, return size or false if full
  def self.next_bucket(size)
    index  = LOCKER_SIZES.index(size)
    length = LOCKER_SIZES.size
    LOCKER_SIZES[index,length].each do |sz|
      hsh = $redis.hgetall(sz).detect{|key,value| value=='false'}
      return hsh[0] if hsh
    end
    false
  end
end