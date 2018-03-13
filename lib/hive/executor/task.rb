module Hive
 class Task
  Result = Struct.new(:result, :peer)
  attr_accessor :service_id, :data
  def initialize data
   @data = data
  end

  #> Send task to worker
  def send_to peer
   peer.semaphore.synchronize do 
    data = { id: service_id, data: self.data }.to_json
    buffer = Buffer::Writer.new data
    buffer.segments.each { |segment| peer.send_data segment }
    peer.last_used_at = Time.now
    sleep 0.3
   end
  end

  # -------------------
  #    CLASS METHODS
  # ------------------

  class << self

   #> Get next worker and send task 
   def send_with_worker task
    return raise_no_task unless task
    worker = Executor::Server.next_worker
    { worker: worker, future: Celluloid::Future.new { task.send_to(worker) } }
   end

   # Get service that sent task
   # and trigger perform on callback object that was set
   def handle_result! json, peer
    Logger.info 'Processing data received from peer: ' + peer.to_s
    service = Executor::Service.get json[:service_id]
    service.trigger.send :perform, Result.new(json, peer) 
   end

   private
   def raise_no_task
    Logger.error 'No task provided.'
   end

  end

 end
end