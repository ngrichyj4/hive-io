require File.expand_path('../dependencies', File.dirname(__FILE__))
require 'json'
require 'pp'
require 'eventmachine'
require 'colorize'
require 'awesome_print'
require 'celluloid/current'
require 'hive/error'
require 'hive/logger'
require 'hive/buffer'
require 'hive/executor/service'
require 'hive/executor/server'
require 'hive/executor/task'
require 'hive/executor/worker'
require 'hive/worker/worker'
require 'hive/worker/client'
require 'hive/worker/queue'
require 'hive/worker/executor'

Celluloid.boot
STDOUT.sync = true
Hive::Logger.stdout = true
Thread.abort_on_exception=true
module Hive
 
end