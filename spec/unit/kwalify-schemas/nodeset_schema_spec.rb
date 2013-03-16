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

  examples = ['nodeset_example1.yml']
  examples.each do |ex|
    it "should not return an error for #{ex}" do
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
end
