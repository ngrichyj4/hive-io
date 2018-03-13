# master arg or MASTER_NODE env
module Hive
 module Worker
  POLL_INTERVAL = 10
  POOL_SIZE     = ARGV[3] || ENV['THREAD_POOL'] || 10
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods

   # If executor not connected to worker
   # try to establish connection every POLL_INTERVAL
   def run!
    Logger.warn 'Initializing, please wait.'
    init_error_handler
    EventMachine.run do
     EventMachine.add_periodic_timer(Worker::POLL_INTERVAL) do
      connect! unless Worker::Client.executor 
     end
    end
   end

   # Establish connection to server
   protected
    def connect! 
     ipaddr = ARGV[1] || ENV['MASTER_NODE']
     raise_ippaddr unless ipaddr
     Worker::Client.connect! *ipaddr.split(':') 
    end

    def init_error_handler
     EM.error_handler{ |e| 
      Logger.error "Error raised: #{e.message}"
      Logger.error "Backtrace:\n\t#{e.backtrace.join("\n\t")}"
     }
    end

    def raise_ippaddr
     text = 'No master node ip address specified.'
     Logger.error text, Hive::SocketError.new(text)
    end

  end

 end
end
