require_relative '../model/thrift_string.rb'
describe ThriftType::String do
  
 it "returns an iOS boolean with a name" do

  ThriftType::String.to_ios("var1").should == 'NSString *var1'

 end


end