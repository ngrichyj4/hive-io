module Hive
 class Logger 

  class << self
   attr_accessor :stdout

   def info text
    puts '[info] '.green + Time.now.to_s + ' -- ' + text if @stdout
   end

   def warn text
    puts '[warn] '.yellow + Time.now.to_s + ' -- ' + text if @stdout
   end

   def error text, err=nil
    puts '[err] '.red + Time.now.to_s + ' -- ' + text if @stdout
    raise err if err
   end

  end

 end
end