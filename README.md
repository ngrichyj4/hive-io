# Hive

A distributed executor service in ruby to execute multiple tasks concurrently across multiple machines (physical hosts, vm). For instance if you want to process a bunch of tasks concurrently but can't handle the entire task on a single machine. You can use `Hive` to distribute the task across multiple machines and retrieve the results as if you were using a single machine while the jobs are distributed seamlessly across multiple nodes.

## Installation
You need to clone the git repo and build the gem locally:

```bash
$ git clone https://github.com/ngrichyj4/hive-io && cd hive-io
$ gem build hive-io.gemspec
```

And then execute:

    $ gem install hive-io-version.gem # use appropriate version

## Usage

Require `hive` in your project and setup the worker nodes. 

### Executor service
The executor service provides an interface for you to distribute tasks to multiple workers. Each task will assigned to a node in the network for execution.

*`NOTE`: Each task will be executed externally from the current process and must be `atomic`, i.e self containing and does not depend on any variables, methods, classes i.e objects from the current process.*

`#consumer.rb`
```ruby
require 'hive' 
Hive::Executor::Service.boot  #> Start the executor service on ::3333 for worker nodes to connect to.

class Consumer
 attr_accessor :service
 def initialize
  @service = Hive::Executor::Service.create(
   node: {
    trigger: self  #> an instance of a object that responds to #perform to receive node results
   }
  )

  get!
 end

 def get!
  urls = ['www.example1.com','www.example2.com', 'www.example3.com']
  urls.map do |uri| 
   @service.execute! do
    #> Each worker will be assigned a uri to open
    Hive::Task.new %{ 
     uri = "#{uri}"
     open(uri).read 
    } #> Atomic  
   end
  end
 end

 # Will be triggered by executor with each result
 def perform arg
  p arg.result
 end
end
```

In the above `get!` example each worker will be sent the string `"open('www.example(i).com').read"`. This string will be evaluated with `eval` by the worker and the result will be returned. This task is atomic because the `uri` variable was evaluated in the main process and passed along in the string.

#### Wrong way
The incorrect way to write `get!` would have been:
```ruby
def get!
 urls = ['www.example1.com','www.example2.com', 'www.example3.com']
 urls.map do |uri| 
  service.execute! do

   Hive::Task.new %{ 
    open(uri).read 
   } #> Wrong  

  end
 end
end
```

In this example, the following string will be sent instead `"open(uri).read"`. The worker does not know what `uri` is and you would get `NameError: undefined local variable or method "uri" for ...`


#### Custom config
You can also specify a custom `ipaddr:port` the executor service should bind to: 
```ruby 
Hive::Executor::Service.boot ipaddr: '0.0.0.0', port: '7556' #> Default is 127.0.0.1:7556
```

To check if the executor service is running:

    $ lsof -i :7556 
    COMMAND   PID      USER   FD   TYPE             DEVICE SIZE/OFF NODE NAME
    ruby    16443 ngrichyj4   11u  IPv4 0x59aa58819e8169df      0t0  TCP localhost:7556 (LISTEN)

#### Stop service
To stop the executor service your can either call `Hive::Executor::Server.stop!` or from the terminal run:

    $ kill -9 [PID] # where PID is the process id.
 
### Worker node
Configure the worker node with the `ip address` of where the `executor service` is been used (i.e your project). The worker node will make multiple attempts to connect to the executor until a connection as been established. The worker will then receive and execute tasks from the executor service and send back the result(s). 

*`IMPORTANT`: You need to setup the worker node to include all the libraries that will be required during the execution of your task.* 

#### Sample worker
`#worker.rb`
```ruby
# Prepare worker to include all gems that will be needed by executor service
# You can use bundler to include the gems from your Gemfile 
require 'rubygems'
require 'hive'
require 'bundler/setup'
Bundler.require(:default)   
require 'open-uri' #> required since been used by executor service task
class Worker
 include Hive::Worker
end

Worker.run! if __FILE__==$0
```

You can then start multiple instances of the worker on one or more machines.
*`Tip`: Use a docker swarm or kubernetes :)*

```bash
ruby worker.rb --master 127.0.0.1:7556 --threadpool 10 # Worker will continuously poll executor until a connection is established
```

`threadpool` option specifies how many concurrent task each worker node should execute simultaneously.

## Docker compose example
You should ideally deploy the worker node on thousands of containers across multiple machines using a docker swarm and enjoy process monitoring with automatic restarts if the worker crashes. I've included a simple example that uses `docker-compose` with `docker` to spawn multiple workers on a single machine See [examples](examples). Or you can use a `docker swarm` instead for a multi node cluster.


### Build image
You need to have `docker` and `docker-compose` installed on your machine. If you're using ubuntu you can use the installation scripts found in [scripts](scripts).

Clone the project if you haven't already and from the `examples` directory change the `MASTER_NODE` entry in `docker-compose.yml` to the `ip address` of your executor node. If you're testing locally on linux use `127.0.0.1` on Mac OSX use your local ip address instead ex: `192.168.1.88`. 

*`IMPORTANT:` If you are testing locally on `Mac OSX`. You need to bind the executor service to `0.0.0.0`. If not, the workers inside the docker container will not be able to connect to it*

And then execute the following commands in the `examples` directory:

    $ docker-compose build
    $ docker-compose up -d --scale worker=100
    $ docker-compose logs -f #> to view logs


You should now have 50 workers ready for use from your executor service.


## Contributing

1. Fork it ( https://github.com/ngrichyj4/hive-io/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
