require 'optparse'
require_relative 'ios_gen'

def base_gen(options)
  command = 'thrift -out %s --gen %s %s ' % [options[:out], options[:lang], options[:tfile]]
  system command
end

options = { }
OptionParser.new do |opts|
 # Set a banner, displayed at the top
 # of the help screen.
 opts.banner = "Usage: ruby thriftplus.rb --out=/Users/myusername/Documents/mythriftfiles(optional) --lang cocoa --tfile chat.thrift"
 # Define the options, and what they do

 options[:out] = Dir.pwd
 opts.on( '--out dir', 'Set the ouput location for generated files. (no gen-* folder will be created)' ) do |out|
   options[:out] = out
 end 

 options[:tfile] = nil
 opts.on( '--tfile thrift_file', 'Specifies the thrift file' ) do |l|
   options[:tfile] = l
 end 

 options[:lang] = nil
 opts.on( '--lang target_lanaguage', 'Specifies the lanaguage target' ) do |l|
   options[:lang] = l
 end  

 opts.on( '--help', 'Displays help this screen' ) do
   puts opts
   exit
 end
end.parse!

if options[:lang] == 'cocoa'
  base_gen(options)
  run(options[:tfile], options[:out])
end

