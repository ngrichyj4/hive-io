# Handles outbound connections to executor
module Hive
 module Worker
  class Client
   class << self; attr_accessor :executor; end
   PORT = '7556'

   # Establish connection to master node
   class << self 
    def connect! ipaddr, port=nil
     port ||= Client::PORT
     Logger.warn 'Trying to establish connection to: ' + ipaddr + ':' + port.to_s
     EventMachine.run do
      EventMachine::connect(ipaddr, port, Executor::Connection) do |executor|
       executor.ipaddr = ipaddr
       executor.port = port
       executor.client = self
       executor.queue = Worker::Queue.pool(size: Worker::POOL_SIZE.to_i)
       executor.reader = Buffer::Reader.new
       Worker::Client.executor = executor
      end
     end
    end
   end

  
  end
 end
end