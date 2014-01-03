require_relative 'generator/ios.rb'
require 'stark/parser'
require 'stark'
require 'optparse'
require 'fileutils'
require_relative 'version'


class String
  def uncapitalize 
    self[0, 1].downcase + self[1..-1]
  end
end

def write_file_at(file, content)
  FileUtils.mkdir_p(File.dirname(file))
  File.open(file, 'w') do |file|
    file.write(content)
  end
end

def local_file_at(file)
  path = (File.expand_path("..", __FILE__)).gsub("/lib", "") + "/" + file
  file = File.open(path, "rb")
  contents = file.read
  file.close
  contents
end

def run(file, out_dir)
  ios_category = local_file_at('templates/ios/category.mustache')
  ios_category_header = local_file_at('templates/ios/category_header.mustache')

  contents = Stark::Parser.read_file(file)
  services = Stark::Parser.ast(contents).select{|x| x.is_a?(Stark::Parser::AST::Service) }
  services.each do |x|
    master_model = { :service_name => x.name, :functions => [], :file_name => File.basename(file).split(".")[0], :version => gen_version }
    x.functions.each do |y|
      a = y.arguments.collect{|z| IOS.convert_return_type(z.type) }
      my_return = IOS.convert_return_type(y.return_type)
      a << IOS.block_parameter('void', [IOS.add_var_to_type(my_return, 'results')])
      var_names = []
      y.arguments.each do |b|
        var_names << b.name
      end
      var_names << 'onCompletion'
      arg_names = y.arguments.collect{|d| d.name }
      
      var_ids = var_names.dup
      var_ids[var_ids.length - 1] = "completionBlock"

      var_names[0] = y.name

      var_names = var_names
      exceptions = []

      if y.throws
        y.throws.each do |s|
          type = s.type
          param = s.type.uncapitalize
          exceptions << { :exception_name => param + 'Block', :exception_type => type } 
          var_ids << param + 'Block'
          a << IOS.block_parameter('void', [IOS.struct_var(type, 'exception')])
          var_names << 'on' + type
        end
      end

      var_ids << 'tExceptionBlock'
      a << IOS.block_parameter('void', [IOS.struct_var('TException', 'exception')])
      var_names << 'onTException'


      exceptions << { :exception_name => 'tExceptionBlock', :exception_type => 'TException' } 

      params = var_names.zip(a, var_ids).collect {|q| { :var_name  => q[0], :var_type => q[1], :var_id => q[2] }}
      

      signature = IOS.method_signature('void', params)

      master_model[:functions] << { :service_name => x.name, :signature => signature, :method_call => IOS.method_call('self', y.name, arg_names), :return_var => IOS.add_var_to_type(my_return, 'results'), :has_return_var => IOS.add_var_to_type(my_return, 'results') != '', :exceptions => exceptions  }
    end
    mfile = File.join(out_dir, master_model[:service_name] + "Client+Async.m")
    hfile = File.join(out_dir, master_model[:service_name] + "Client+Async.h")
    write_file_at(mfile, Mustache.render(ios_category, master_model))
    write_file_at(hfile, Mustache.render(ios_category_header, master_model))
  end
end