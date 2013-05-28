require './spec/spec_helper'
require "./lib/mass_insert"
require "./spec/dummy_models/test"

describe "Model" do

  before :each do
    @values, @options  = [], {}
    @value_hash = {
      :name    => "some_name",
      :email   => "some_email",
      :age     => 20,
      :active  => true,
      :checked => true
    }
    User.delete_all
  end

  context "when is used without options" do
    context "when value hashes have string keys" do
      before :each do
        value_hash = {
          "name"    => "some_name",
          "email"   => "some_email",
          "age"     => 20,
          "active"  => true,
          "checked" => true
        }
        5.times{ @values << value_hash }
        User.mass_insert(@values, @options)
      end

      it "should save correct values" do
        User.first.name.should eq("some_name")
      end

      it "should have saved 5 records" do
        User.count.should eq(5)
      end
    end

    context "when value hashes have symbol keys" do
      before :each do
        5.times{ @values << @value_hash }
        User.mass_insert(@values, @options)
      end

      it "should save correct values" do
        User.first.age.should eq(20)
      end

      it "should have saved 5 records" do
        User.count.should eq(5)
      end
    end

    context "when value hashes have symbol and string keys" do
      before :each do
        value_hash = {
          "name"    => "some_name",
          :email    => "some_email",
          "age"     => 20,
          :active   => true,
          "checked" => true
        }
        5.times{ @values << value_hash }
        User.mass_insert(@values, @options)
      end

      it "should save correct values" do
        User.first.email.should eq("some_email")
      end

      it "should have saved 5 records" do
        User.count.should eq(5)
      end
    end

    it "should save if values cointains 1200 records" do
      1200.times{ @values << @value_hash }
      User.mass_insert(@values, @options)
      User.count.should eq(1200)
    end
  end

  context "when is used with options" do
    context "when the table name doesn't exit" do
      it "should not save any record" do
        5.times{ @values << @value_hash }
        @options.merge!(:table_name => "countries")
        lambda{ User.mass_insert(@values, @options) }.should raise_exception
      end
    end

    context "when the class name not inherit from ActiveRecord" do
      it "should not save any record" do
        5.times{ @values << @value_hash }
        @options.merge!(:class_name => Test)
        lambda{ User.mass_insert(@values, @options) }.should raise_exception
      end
    end
  end
end
