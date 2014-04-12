require 'spec_helper'
require 'bank_routing'

describe BankRouting do
	it "should have a VERSION constant" do
		subject.const_get('VERSION').should_not be_empty
	end
end

describe RoutingNumber do

	it "should get a number with no config" do
		RoutingNumber.get(121000358)[:name].should eq("Bank of America")
	end

	it "should take a config and reload" do
		require 'bank_routing/storage/redis'
		RoutingNumber.store_in :redis
		RoutingNumber.get(121000358)[:name].should eq("Bank of America")
	end

	it "should load fresh data" do
		require 'bank_routing/storage/redis'
		RoutingNumber.store_in :redis
		RoutingNumber.get(121000358)[:name].should eq("Bank of America")
		RoutingNumber.fetch_fresh_data!(false)
		RoutingNumber.get(121000358)[:name].should eq("Bank of America")
	end

	it "should include metadata" do
		RoutingNumber.get(114994196)[:prepaid_card].should eq(true)
	end

end
