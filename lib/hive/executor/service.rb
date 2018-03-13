module Hive
 module Executor
  class Service
   TASK_POOLSIZE = 100
   attr_accessor :id, :trigger, :tasks
   def initialize params
    @id   = SecureRandom.uuid
    @tasks = []
    @trigger = params[:node][:trigger]
    Service.set id, self #> Keep record of all executor sevices
   end

   #> Distribute tasks to connected workers
   def execute! &block
    task = block.call if block_given?
    return raise_no_workers if Server::workers.empty?
    task.service_id = id; self.tasks << task
    # Get worker and send task
    data = Task.send_with_worker(task)
    Logger.info 'Queued task ' + task.to_s +  ' for worker: ' + data[:worker].to_s

    data
   end
   
   def raise_no_workers
    Logger.error 'Cannot execute tasks because workers are connected.'
    nil
   end

   # -------------------
   #    CLASS METHODS
   # ------------------

   class << self
    attr_accessor :services
    #> Create new executor service instance 
    def create params
     raise_start_server unless Server::node
     new params
    end

    def raise_start_server
     text = 'Hive is not started; use Hive.boot'
     Logger.error text, StandardError.new(text)
    end

    #> Start executor service service in background
    def boot params={}
     Server.node = Server.start! params
     Server.semaphore = Mutex.new
     Server.workers = []; true
    end

    #> Set executor service to store
    def set id, service
     @services ||= {}
     @services[id] = service
    end

    #> Get executor service from store
    def get id
     @services[id]
    end

   end

  end
 end
end