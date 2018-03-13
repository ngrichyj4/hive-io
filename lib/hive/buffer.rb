#
# => Slice up data into chunks of specified byte size
# => then append terminator to the end of string.
#

module Hive
 module Buffer
  DELIMITER = '[---(END)---]'

  class Writer
   attr_accessor :data, :bytesize, :segments
   BYTESIZE = 16_000

   def initialize data, bytesize=BYTESIZE
    @data = data 
    @bytesize = bytesize
    @segments = []
    segment!
   end


   def segment!
    @data.bytes.each_slice(@bytesize){ |slice| @segments << slice.pack("C*") }
    if @segments.last.bytesize < (@bytesize - (DELIMITER.bytesize * 2))
     @segments.last << Buffer::DELIMITER 
    else 
     @segments << Buffer::DELIMITER
    end
   end
  end

  #
  # => Read data from buffer until terminator reached
  #

  class Reader
   attr_accessor :data, :delimiter
   def initialize delimiter=Buffer::DELIMITER
    @data = []
    @delimiter = delimiter
   end

   def ingest data
    @data << data.delete("\n")
   end

   def read
    @data.join.split(Buffer::DELIMITER)
   end

   def read_and_clear!
    data = read; @data.clear; data
   end

   def ingested?
    !@data.select{|data| data.end_with? @delimiter }.empty?
   end
  end

 end
end