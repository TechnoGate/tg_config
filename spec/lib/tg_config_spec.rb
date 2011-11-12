require 'spec_helper'

describe TgConfig do
  before(:each) do
    @config = {:submodules => [:pathogen]}
    @config_path = '/valid/path'
    @invalid_config_path = '/invalid/path'
    YAML.stubs(:load_file).with(@config_path).returns(@config)
    TgConfig.send(:class_variable_set, :@@config_file, @config_path)

    ::File.stubs(:exists?).with(@config_path).returns(true)
    ::File.stubs(:readable?).with(@config_path).returns(true)
    ::File.stubs(:writable?).with(@config_path).returns(true)

    ::File.stubs(:exists?).with(@invalid_config_path).returns(false)
    ::File.stubs(:readable?).with(@invalid_config_path).returns(false)
    ::File.stubs(:writable?).with(@invalid_config_path).returns(false)

    @file_handler = mock "file handler"
    @file_handler.stubs(:write)

    ::File.stubs(:open).with(@config_path, 'w').yields(@file_handler)
  end

  describe "@@config" do
    it "should have a class_variable @@config" do
      lambda { subject.send(:class_variable_get, :@@config) }.should_not raise_error NameError
    end
  end

  describe "@@config_file" do
    it "should have a class_variable @@config_file" do
      lambda {subject.send(:class_variable_get, :@@config_file) }.should_not raise_error NameError
    end
  end

  describe "#config_file" do
    it { should respond_to :config_file }

    it "should return @@config_file" do
      subject.send(:class_variable_set, :@@config_file, @invalid_config_path)

      subject.config_file.should == @invalid_config_path
    end

    it "should raise ConfigFileNotSetError if @@config_file is not set" do
      subject.send(:class_variable_set, :@@config_file, nil)

      lambda { subject.config_file }.should raise_error TgConfig::ConfigFileNotSetError
    end
  end

  describe "#config_file=" do
    it { should respond_to :config_file= }

    it "should set @@config_file" do
      subject.config_file = @invalid_config_path
      subject.config_file.should == @invalid_config_path
    end
  end

  describe "#check_config_file" do
    before(:each) do
      TgConfig.stubs(:initialize_config_file)
    end

    it { should respond_to :check_config_file }

    it "should call File.exists?" do
      ::File.expects(:exists?).with(@config_path).returns(true).once

      subject.send(:check_config_file)
    end

    it "should call File.readable?" do
      ::File.expects(:readable?).with(@config_path).returns(true).once

      subject.send(:check_config_file)
    end

    it "should call File.writable?" do
      ::File.expects(:writable?).with(@config_path).returns(true).once

      subject.send(:check_config_file, true)
    end

    it "should not call File.writable? if no arguments were passed" do
      ::File.expects(:writable?).with(@config_path).returns(true).never

      subject.send(:check_config_file)
    end

    it "should raise TgConfig::NotReadableError if config not readable" do
      TgConfig.stubs(:config_file).returns(@invalid_config_path)
      ::File.stubs(:readable?).with(@invalid_config_path).returns(false)

      lambda { subject.send(:check_config_file) }.should raise_error TgConfig::NotReadableError
    end

    it "should raise TgConfig::NotWritableError if config not readable" do
      TgConfig.stubs(:config_file).returns(@config_path)
      ::File.stubs(:writable?).with(@config_path).returns(false)

      lambda { subject.send(:check_config_file, true) }.should raise_error TgConfig::NotWritableError
    end

  end

  describe "#initialize_config_file" do
    it { should respond_to :initialize_config_file }

    it "should be able to create the config file from the template" do
      config_file = mock
      config_file.expects(:write).once
      File.expects(:open).with(TgConfig.config_file, 'w').yields(config_file).once

      subject.send :initialize_config_file
    end
  end

  describe "#parse_config_file" do
    before(:each) do
      TgConfig.send(:class_variable_set, :@@config, nil)
      TgConfig.stubs(:initialize_config_file)
    end

    it { should respond_to :parse_config_file }

    it "should parse the config file and return an instance of HashWithIndifferentAccess" do
      subject.send(:parse_config_file).should be_instance_of HashWithIndifferentAccess
    end
  end

  describe "#[]" do
    before(:each) do
      TgConfig.send(:class_variable_set, :@@config, nil)
      TgConfig.stubs(:initialize_config_file)
    end

    it "should call check_config_file" do
      TgConfig.expects(:check_config_file).once

      subject[:submodules]
    end

    it "should call parse_config_file" do
      TgConfig.expects(:parse_config_file).returns(@config).once

      subject[:submodules]
    end
  end

  describe "#[]=" do
    after(:each) do
      TgConfig.send(:class_variable_set, :@@config, nil)
    end

    it { should respond_to :[]= }

    it "should set the new config in @@config" do
      subject[:submodules] = [:pathogen, :github]
      subject.send(:class_variable_get, :@@config)[:submodules].should ==
        [:pathogen, :github]
    end
  end

  describe "#write_config_file" do
    before(:each) do
      subject.send(:class_variable_set, :@@config, @config)
      subject.send(:class_variable_get, :@@config).stubs(:to_hash).returns(@config)
    end

    it { should respond_to :write_config_file }

    it "should call to_hash on @@config" do
      subject.send(:class_variable_get, :@@config).expects(:to_hash).returns(@config).once

      subject.send :write_config_file
    end

    it "should call to_yaml on @@config.to_hash" do
      @config.expects(:to_yaml).returns(@config.to_yaml).twice # => XXX: Why twice ?
      subject.send(:class_variable_get, :@@config).stubs(:to_hash).returns(@config)

      subject.send :write_config_file
    end

    it "should call File.open with config_file" do
      ::File.expects(:open).with(@config_path, 'w').yields(@file_handler).once

      subject.send :write_config_file
    end

    it "should write the yaml contents to the config file" do
      @file_handler.expects(:write).with(@config.to_yaml).once
      ::File.stubs(:open).with(@config_path, 'w').yields(@file_handler)

      subject.send :write_config_file
    end

    it "should raise TgConfig::IsEmptyError" do
      subject.send(:class_variable_set, :@@config, nil)

      lambda { subject.send :write_config_file }.should raise_error TgConfig::IsEmptyError
    end
  end

  describe "#save" do
    before(:each) do
      subject.send(:class_variable_set, :@@config, @config)
      subject.send(:class_variable_get, :@@config).stubs(:to_hash).returns(@config)
    end

    it { should respond_to :save }

    it "should call check_config_file to make sure it is writable" do
      TgConfig.expects(:check_config_file).with(true).once

      subject.save
    end

    it "should call write_config_file" do
      TgConfig.expects(:write_config_file).once

      subject.save
    end

    it "should clear the cache" do
    end
  end
end
