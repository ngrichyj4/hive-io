module Hive
 module Executor
  class Server
   HOST = '127.0.0.1'
   PORT = '7556'

   # -------------------
   #    CLASS METHODS
   # ------------------

   class << self 
    attr_accessor :node, :workers, :semaphore

    # Start executor service
    def start! params={}
     port = params[:port] ||= Server::PORT
     ipaddr = params[:ipaddr] ||= Server::HOST
     init_error_handler
     Thread.new do
      EventMachine.run do 
       EventMachine.start_server ipaddr, port, Worker::Connection
       Logger.info 'Hive is running on ' + ipaddr + ':' + port.to_s
      end
     end
    end

    def init_error_handler
     EM.error_handler{ |e| 
      Logger.error "Error raised: #{e.message}"
      Logger.error "Backtrace:\n\t#{e.backtrace.join("\n\t")}"
     }
    end

    # Stop executor service
    def stop!
     @node.kill if @node
    end

    # Get the next available worker based on last used
    def next_worker
     @semaphore.synchronize do
      @workers.rotate!.last
     end
    end

   end

  end
 end
end
