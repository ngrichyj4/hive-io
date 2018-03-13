require 'celluloid/current'

module Hive
 module Worker
  class Queue
   include Celluloid

   def initialize
    init_semaphore! 
   end

   def init_semaphore!
    Queue.semaphore ||= Mutex.new
   end

   # Execute instruction and send back the result
   def execute json, peer
    data = { status: 'ok', service_id: json[:id], peer_id: peer.id, result: eval(json[:data]) }
    respond_with peer: peer, data: data
   rescue => e
    data = { status: 'err', service_id: json[:id], peer_id: peer.id, result: e.message }
    respond_with peer: peer, data: data
   end

   # => Breaks up data into buffers and sends it over the network to peer
   def respond_with params
    Queue.semaphore.synchronize do
     Logger.warn 'Acquiring MUTEX' 
     buffer = Buffer::Writer.new params[:data].to_json
     buffer.segments.each { |segment| params[:peer].send_data(segment) }
     Logger.info 'Sent ' + buffer.segments.to_s + ' to ' + params[:peer].to_s
     sleep 1
    end
   end

   class << self
    attr_accessor :semaphore
    def add! data, peer
     Logger.info 'Processing data: ' + data.to_s + ' from peer: ' + peer.to_s
     result = peer.queue.async.execute(data, peer)
    end
   end

  end
 end
end