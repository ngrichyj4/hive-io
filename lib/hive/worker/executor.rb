module Hive
 module Executor
  class Connection < EventMachine::Connection
   attr_accessor :id, :client, :ipaddr, :port, :queue, :reader

   def initialize
    @id = SecureRandom.uuid
   end

   def post_init
    Logger.info '-- Connected to executor peer.'
   end 

   #
   # => Handle data received
   #
   def receive_data(data)
    Logger.info '-- Received data: ' + data.to_s + ' from executor: '+ self.to_s
    reader.ingest data
    handler reader.read_and_clear!, self if reader.ingested?
   end
   
   #
   # => Remove peer from network, if connection lost
   #
   def unbind
    Logger.warn '-- Peer connection lost: '+ self.to_s
    return unless Worker::Client::executor
    Worker::Client.executor.cleanup!
   end

   def handler data, peer
    data.map {|item| trigger_handler item, peer }
   end

   def trigger_handler data, peer
    json = JSON.parse(data, symbolize_names: true)
    Worker::Queue.add! json, peer
   end

   def cleanup!
    return unless Worker::Client::executor
    Worker::Client.executor.queue.terminate rescue nil
    Worker::Client.executor = nil
   end


  end
 end
end