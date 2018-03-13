require 'rubygems'
require 'hive'
require 'bundler/setup'
Bundler.require(:default)
require 'open-uri' #> required since been used by executor service task

class Worker
 include Hive::Worker
end

Worker.run! if __FILE__==$0