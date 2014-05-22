require File.join(File.dirname(__FILE__), "helpers")
require "sensu/extensions/loader"

describe "Sensu::Extensions::Loader" do
  include Helpers

  before do
    @loader = Sensu::Extensions::Loader.new
    @assets_dir = File.join(File.dirname(__FILE__), "assets")
    @extension_dir = File.join(@assets_dir, "extensions")
    @extension_file = File.join(@extension_dir, "test.rb")
  end

  it "can provide the extensions loader API" do
    @loader.should respond_to(:load_file, :load_directory, :warnings, :loaded_files)
  end

  it "can load an extension from a file" do
    @loader.load_file(@extension_file)
    @loader.warnings.size.should eq(1)
    @loader.loaded_files.size.should eq(1)
    @loader.loaded_files.first.should eq(File.expand_path(@extension_file))
    extension = Sensu::Extension::Test.new
    extension.should respond_to(:name, :description, :definition, :safe_run, :stop, :has_key?, :[])
  end

  it "can attempt to load an extension with a script error" do
    script = File.join(@extension_dir, "error.rb")
    @loader.load_file(script)
    warnings = @loader.warnings
    warnings.size.should eq(3)
    messages = warnings.map do |warning|
      warning[:message]
    end
    messages.should include("loading extension file")
    messages.should include("ignoring extension")
    @loader.loaded_files.should be_empty
  end

  it "can load extensions from a directory" do
    @loader.load_directory(@extension_dir)
    @loader.warnings.size.should eq(5)
    @loader.loaded_files.size.should eq(1)
    extension = Sensu::Extension::Test.new
    extension.should respond_to(:name, :description, :definition, :safe_run, :stop, :has_key?, :[])
  end

  it "can attempt to load extensions from a nonexistent directory" do
    @loader.load_directory("/tmp/bananaphone")
    @loader.warnings.size.should eq(1)
    @loader.loaded_files.should be_empty
  end
end
