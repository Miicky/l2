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
    while (Time.now <= time + Count.execute_time) do 
      if next_request = @storage.next_request
        Count.increment_processed 
        puts "sleep #{next_request}"
        sleep time_processed
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
   current_storage.count == storage_limit ? Count.increment_skiped : @current_storage << request
  end

  def remove(request)
    @current_storage.delete(request)
  end  

  def next_request
    request = @current_storage.last
    remove(request)
  end
end

class Program 
  def self.call
    osm = OSM.new
    time = Time.now 
    i = 0
    process_thread = Thread.new { osm.process(time) }
    requests_flow_thread = Thread.new { 
      while (Time.now <= time + Count.execute_time) do 
        osm.add_to_storage(Count.count_requests)
        Count.increment_count_requests
      end
    }

    [process_thread, requests_flow_thread].map(&:join)
  end
end

class Count
  @@skiped = 0
  @@processed = 0
  @@count_requests = 0
  @@execute_time = 3

  def self.execute_time 
    @@execute_time
  end

  def self.increment_skiped 
    @@skiped += 1
  end
  def self.increment_processed
    @@processed +=1
  end
  def self.increment_count_requests
    @@count_requests +=1
  end

  def self.count_requests
    @@count_requests
  end

  def self.skiped 
    @@skiped
  end

  def self.processed
    @@processed
  end
end




program = Program.call

puts "requests = #{Count.count_requests}"
puts "Processed = #{Count.processed}"
puts "Skipped = #{Count.skiped}"
puts "Missed = #{Count.count_requests - Count.processed - Count.skiped}"
