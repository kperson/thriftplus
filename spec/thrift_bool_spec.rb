require_relative '../model/thrift_bool.rb'

describe ThriftType::BOOL do
  
 it "returns an iOS boolean with a name" do

  ThriftType::BOOL.to_ios("var1").should == 'BOOL var1'

 end


end