require 'spec_helper'
require 'kwalify'

describe 'nodeset_schema' do
  let(:schema) do
    YAML.load_file(schema_path + 'nodeset_schema.yml')
  end
  let(:validator) do
    validator = Kwalify::Validator.new(schema)
  end
  let(:parser) do
    parser = Kwalify::Yaml::Parser.new(validator)
  end

#  examples = ['nodeset_example1.yml']
  Pathname.glob(fixture_path + 'nodeset_example*.yml').each do |ex|
    it "should not return an error for #{ex.basename}" do
      ydoc = parser.parse_file(fixture_path + ex)
      errors = parser.errors
      if errors && !errors.empty?
        errors.each do |e|
          puts "line=#{e.linenum}, path=#{e.path}, mesg=#{e.message}"
        end
      end
      errors.should == []
    end
  end

  it "my own .nodeset.yml should validate" do
    ydoc = parser.parse_file(root_path + '.nodeset.yml')
    errors = parser.errors
    if errors && !errors.empty?
      errors.each do |e|
        puts "line=#{e.linenum}, path=#{e.path}, mesg=#{e.message}"
      end
    end
    errors.should == []
  end
end
