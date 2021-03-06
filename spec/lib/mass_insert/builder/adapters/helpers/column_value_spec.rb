require 'spec_helper'

describe MassInsert::Builder::Adapters::Helpers::ColumnValue do
  let(:class_name) { User }
  let(:row) {{ :name	=> "name", :age	=> 10 }}
  let(:column){ :name }
  let!(:subject){ described_class.new(row, column, class_name) }

  describe "#initialize" do
    it "sets class_name attribute" do
      expect(subject.class_name).to eq(class_name)
    end

    it "sets column attribute" do
      expect(subject.column).to eq(column)
    end

    it "sets row attribute" do
      expect(subject.row).to eq(row)
    end
  end

  describe "#column_type" do
    it "returns column type symbol" do
      subject.stub(:class_name).and_return(User)
      subject.class_name.columns_hash["name"].stub(:type).and_return(:column_type)
      expect(subject.column_type).to eq(:column_type)
    end
  end

  describe "#colum_value" do
    it "returns row value to this column" do
      expect(subject.column_value).to eq("name")
    end
  end

  describe "#default_value" do
    context "when default_db_value is nil" do
      it "returns 'null' string" do
        subject.stub(:default_db_value).and_return(nil)
        expect(subject.default_value).to eq("null")
      end
    end

    context "when default_db_value is not nil" do
      it "returns the correct value" do
        subject.stub(:default_db_value).and_return("default_value")
        expect(subject.default_value).to eq("default_value")
      end
    end
  end

  describe "#default_db_value" do
    it "returns the default database value" do
      subject.stub(:class_name).and_return(User)
      subject.class_name.columns_hash["name"].stub(:default).and_return(:default_db_value)
      expect(subject.default_db_value).to eq(:default_db_value)
    end
  end

  describe "#build" do
    context "when column_value is nil" do
      it "returns the default value" do
        subject.stub(:column_value).and_return(nil)
        subject.stub(:default_value).and_return("default_value")
        expect(subject.build).to eq("default_value")
      end
    end

    context "when column_value is not nil" do
      it "calls a method according to column type" do
        subject.stub(:column_type).and_return("string")
        subject.stub(:column_value_string).and_return("column_value_string")
        expect(subject.build).to eq("column_value_string")
      end
    end
  end

  [
    :string,
    :text,
    :date,
    :time,
    :datetime,
    :timestamp,
    :binary
  ].each do |column_type|
    method = :"column_value_#{column_type}"

    describe "##{method.to_s}" do
      it "returns the column value" do
        subject.stub(:column_value).and_return("name")
        expect(subject.send(method)).to eq("'name'")
      end
    end
  end

  describe "#column_value_integer" do
    context "when is a integer value" do
      it "returns the same integer value" do
        subject.stub(:column_value).and_return(20)
        expect(subject.column_value_integer).to eq("20")
      end
    end

    context "when is not a integer value" do
      it "converts it to integer value" do
        subject.stub(:column_value).and_return("name")
        expect(subject.column_value_integer).to eq("0")
      end
    end
  end

  [:decimal, :float].each do |column_type|
    method = :"column_value_#{column_type}"

    describe "##{method.to_s}" do
      context "when is a decimal value" do
        it "returns the same decimal value" do
          subject.stub(:column_value).and_return(20.5)
          expect(subject.send(method)).to eq("20.5")
        end
      end

      context "when is not a decimal value" do
        it "converts it to decimal value" do
          subject.stub(:column_value).and_return("name")
          expect(subject.send(method)).to eq("0.0")
        end
      end
    end
  end

  describe "#column_value_boolean" do
    it "calls a method according to database adapter" do
      MassInsert::Builder::Utilities.stub(:adapter).and_return("mysql2")
      subject.stub(:mysql2_column_value_boolean).and_return("boolean_value")
      expect(subject.column_value_boolean).to eq("boolean_value")
    end
  end

  [
    :mysql2,
    :postgresql,
  ].each do |adapter|
    method = :"#{adapter}_column_value_boolean"

    describe "##{method.to_s}" do
      context "when column_value method return true" do
        it "returns true string" do
          subject.stub(:column_value).and_return(true)
          expect(subject.send(method)).to eq("true")
        end
      end

      context "when column_value method return false" do
        it "returns false string" do
          subject.stub(:column_value).and_return(false)
          expect(subject.send(method)).to eq("false")
        end
      end
    end
  end

  [
    :sqlite3,
    :sqlserver,
  ].each do |adapter|
    method = :"#{adapter}_column_value_boolean"

    describe "##{method.to_s}" do
      context "when column_value method return true" do
        it "returns true string" do
          subject.stub(:column_value).and_return(true)
          expect(subject.send(method)).to eq("1")
        end
      end

      context "when column_value method return false" do
        it "returns false string" do
          subject.stub(:column_value).and_return(false)
          expect(subject.send(method)).to eq("0")
        end
      end
    end
  end
end
