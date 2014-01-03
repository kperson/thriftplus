require 'stark/parser'
require 'stark'
require 'mustache'

module IOS

  def self.block_parameter(block_return_type, parameters)
    "%s(^)(%s)" % [block_return_type, parameters.join(", ")]
  end

  def self.method_signature(return_type, parameters, object_method = true)
    definition = (parameters.collect{|parameter| 
      parameter[:var_type] ? "%s:(%s)%s" % [parameter[:var_name], parameter[:var_type], parameter[:var_id]] : parameter[:var_name]
      }).join(" ")
    "%s(%s)%s" % [object_method ? "-" : "+",  return_type, definition]
  end

  def self.method_call(object, method_name, parameters = [])
    has_parameters = parameters && parameters.length > 0
    if has_parameters
      if parameters.length == 1
        "[%s %s:%s]" % [object, method_name, parameters[0]]
      else
        final_parameters = parameters.reverse.take(parameters.length - 1).reverse.collect{|x| x + ":" + x }.join(" ")
        "[%s %s:%s %s]" % [object, method_name, parameters[0], final_parameters]       
      end   
    else
      "[%s %s]" % [object, method_name]
    end
  end

  def self.property(reference_type, atomicity, var_defenition)
    if reference_type || atomicity
      '@property (%s) %s;' % [[reference_type, atomicity].select{|x| x}.join(", "), var_defenition]
    else
      '@property %s;' % [var_defenition]
    end
  end

  def self.object_var(var_type, var_name)
    '%s%s' % [var_type, var_name]
  end

  def self.struct_var(var_type, var_name)
    self.object_var(var_type + " *", var_name)
  end

  def self.bool_var(var_name)
    self.object_var('BOOL ', var_name)
  end

  def self.string_var(var_name)
    self.object_var('NSString *', var_name)
  end

  def self.list_var(var_name)
    self.object_var('NSArray *', var_name)
  end

  def self.set_var(var_name)
    self.object_var('NSSet *', var_name)
  end

  def self.map_var(var_name)
    self.object_var('NSDictionary *', var_name)
  end  

  def self.binary_var(var_name)
    self.object_var('NSData *', var_name)
  end

  def self.i8_var(var_name)
    object_var('int8_t ', var_name)
  end

  def self.i16_var(var_name)
    self.object_var('short ', var_name)
  end 

  def self.i32_var(var_name)
    self.object_var('int ', var_name)
  end 

  def self.i64_var(var_name)
    self.object_var('long ', var_name)
  end   

  def self.double_var(var_name)
    self.object_var('double ', var_name)
  end

  def self.var_from_stark(node, var_name = nil)
    variable_name = var_name ? var_name : node.name
    if node.is_a?(Stark::Parser::AST::Struct)
      self.object_var(node.name + ' *', var_name)
    elsif node.is_a?(Stark::Parser::AST::Field)
      if node.type == 'string'
        self.string_var(variable_name)
      elsif node.type == 'BOOL'
        self.bool_var(variable_name)
      elsif node.type == 'byte'
        self.i8_var(variable_name)
      elsif node.type == 'i16'
        self.i16_var(variable_name)
      elsif node.type == 'i32'
        self.i32_var(variable_name)
      elsif node.type == 'i64'
        self.i64_var(variable_name)
      elsif node.type == 'binary'
        self.binary_var(variable_name)        
      elsif node.type.is_a?(Stark::Parser::AST::List)
        self.list_var(variable_name)
      elsif node.type.is_a?(Stark::Parser::AST::Map)
        self.map_var(variable_name)
      elsif node.type.is_a?(Stark::Parser::AST::Set)
        self.set_var(variable_name)
      end      
    else
      nil
    end
  end

  def self.convert_return_type(return_type)
    variable_name = ''
    if return_type == 'void'
     'void'
    elsif return_type.is_a?(Stark::Parser::AST::Struct)
      self.object_var(return_type.name + ' *', variable_name).strip
    elsif return_type == 'string'
      self.string_var(variable_name).strip
    elsif return_type == 'BOOL'
      self.bool_var(variable_name).strip
    elsif return_type == 'byte'
      self.i8_var(variable_name).strip
    elsif return_type == 'i16'
      self.i16_var(variable_name).strip
    elsif return_type == 'i32'
      self.i32_var(variable_name).strip
    elsif return_type == 'i64'
      self.i64_var(variable_name).strip
    elsif return_type == 'binary'
      self.binary_var(variable_name).strip   
    elsif return_type.is_a?(Stark::Parser::AST::List)
      self.list_var(variable_name).strip
    elsif return_type.is_a?(Stark::Parser::AST::Map)
      self.map_var(variable_name).strip
    elsif return_type.is_a?(Stark::Parser::AST::Set)
      self.set_var(variable_name).strip
    end
  end  

  def self.add_var_to_type(return_type, var_name)
    if return_type == 'void'
      ''
    elsif return_type[-1] == '*'
      return_type + var_name
    else
      return_type + " " + var_name
    end
  end    

end