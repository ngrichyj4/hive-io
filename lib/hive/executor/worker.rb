module Hive
 module Worker
  class Connection < EventMachine::Connection
   attr_accessor :reader, :ipaddr, :port, :semaphore, :connected_at, :last_used_at 

   #> Initialize new worker
   def post_init
    Logger.info '-- New connection from worker peer.'
    port, ip = Socket.unpack_sockaddr_in(get_peername)
    @ipaddr = ip; @port = port
    @reader = Buffer::Reader.new
    @semaphore = Mutex.new 
    @connected_at = Time.now
    @last_used_at = Time.at(0)
    add! self
   end 

   def add! worker
    Hive::Executor::Server.workers.unshift self #> add to front of queue
   end

   #
   # => Handle data received
   #
   def receive_data(data)
    Logger.info '-- Received data from worker: '+ self.to_s
    reader.ingest data
    handler reader.read_and_clear!, self if reader.ingested?
   end
   
   #
   # => Remove peer from network, if connection lost
   #
   def unbind
    Logger.warn '-- Peer connection lost: '+ self.to_s
    Hive::Executor::Server.workers.delete(self)
   end

   def handler data, peer
    data.map {|item| trigger_handler item, peer }
   end

   def trigger_handler data, peer
    json = JSON.parse(data, symbolize_names: true)
    Hive::Task.handle_result! json, peer
   end

  end
 end
end