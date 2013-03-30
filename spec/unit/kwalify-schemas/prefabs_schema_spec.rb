require 'spec_helper'
require 'kwalify'

describe 'prefabs_schema' do
  let(:schema) do
    YAML.load_file(schema_path + 'prefabs_schema.yml')
  end
  let(:validator) do
    validator = Kwalify::Validator.new(schema)
  end
  let(:parser) do
    parser = Kwalify::Yaml::Parser.new(validator)
  end

  it "should not return an error for prefabs.yml" do
    ydoc = parser.parse_file(resources_path + 'prefabs.yml')
    errors = parser.errors
    if errors && !errors.empty?
      errors.each do |e|
        puts "line=#{e.linenum}, path=#{e.path}, mesg=#{e.message}"
      end
    end
    errors.should == []
  end
end
