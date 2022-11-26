require 'pry'

@@execute_time = 3
@@skiped = 0
@@processed = 0

class OSM 
  attr_reader :storage, :time_processed
  def initialize
    @storage_limit = 10
    @storage = Storage.new(10)
    @current_request = nil
    @time_processed = 1
  end

  def add_to_storage(request)
    @storage.add(request)
  end

  def remove_from_storage(request)
    @storage.remove(request)
  end

  def process(time)
    while (Time.now <= time + @@execute_time) do 
      next_request = @storage.next_request
      if next_request
        @@processed += 1 
        puts "sleep #{next_request}"
        sleep time_processed
      else 
        puts "NO REQUEST"
      end
    end
  end
end

# require_relative 'main'
class Storage 
  attr_reader :current_storage, :storage_limit
  def initialize(storage_limit)
    @storage_limit = storage_limit
    @current_storage = []
  end

  def add(request)
    if current_storage.count == storage_limit
      @@skiped += 1 
      return false 
    end
    @current_storage << request
  end

  def remove(request)
    @current_storage.delete(request)
  end  

  def next_request
    request = @current_storage.last
    remove(request)
  end
end

class Request 
  def initialize(time)
    @process = time
  end
end
osm = OSM.new
time = Time.now 
i = 0
a = Thread.new { osm.process(time) }
b = Thread.new { 
  while (Time.now <= time + @@execute_time) do 
    osm.add_to_storage(i)
    i+=1
  end
}

[a,b].map(&:join)
puts "requests = #{i}"
puts "Processed = #{@@processed}"
puts "Skipped = #{@@skiped}"
