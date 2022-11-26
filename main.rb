require 'pry'

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

class Program 
  def initilize 
    # @count_requests = 0
  end

  def call
    osm = OSM.new
    time = Time.now 
    i = 0
    a = Thread.new { osm.process(time) }
    b = Thread.new { 
      while (Time.now <= time + @@execute_time) do 
        osm.add_to_storage(@@count_requests)
        # binding.pry
        @@count_requests +=1 
      end
    }

    [a,b].map(&:join)
  end
end

@@execute_time = 3
@@skiped = 0
@@processed = 0
@@count_requests = 0

program = Program.new
program.call

puts "requests = #{@@count_requests}"
puts "Processed = #{@@processed}"
puts "Skipped = #{@@skiped}"
