require 'spec_helper'

describe TgConfig do
  let(:config) { {:submodules => [:pathogen]} }
  let(:config_path) { '/valid/path' }
  let(:invalid_config_path) { '/invalid/path' }

  subject { TgConfig.new config_path }

  before(:each) do
    YAML.stubs(:load_file).with(config_path).returns(config)
    TgConfig.send(:instance_variable_set, :@config_file, config_path)

    ::File.stubs(:exists?).with(config_path).returns(true)
    ::File.stubs(:readable?).with(config_path).returns(true)
    ::File.stubs(:writable?).with(config_path).returns(true)

    ::File.stubs(:exists?).with(invalid_config_path).returns(false)
    ::File.stubs(:readable?).with(invalid_config_path).returns(false)
    ::File.stubs(:writable?).with(invalid_config_path).returns(false)

    @file_handler = mock "file handler"
    @file_handler.stubs(:write)

    ::File.stubs(:open).with(config_path, 'w').yields(@file_handler)
  end

  describe "#config_file" do
    it { should respond_to :config_file }

    it "should return @config_file" do
      subject.send(:instance_variable_set, :@config_file, invalid_config_path)

      subject.config_file.should == invalid_config_path
    end
  end

  describe "#check_config_file" do
    it { should respond_to :check_config_file }

    it "should call File.exists?" do
      ::File.expects(:exists?).with(config_path).returns(true).once

      subject.send(:check_config_file)
    end

    it "should call File.readable?" do
      ::File.expects(:readable?).with(config_path).returns(true).once

      subject.send(:check_config_file)
    end

    it "should call File.writable?" do
      ::File.expects(:writable?).with(config_path).returns(true).once

      subject.send(:check_config_file, true)
    end

    it "should not call File.writable? if no arguments were passed" do
      ::File.expects(:writable?).with(config_path).returns(true).never

      subject.send(:check_config_file)
    end

    it "should raise TgConfig::NotReadableError if config not readable" do
      ::File.stubs(:readable?).with(config_path).returns(false)

      lambda { subject.send(:check_config_file) }.should raise_error TgConfig::NotReadableError
    end

    it "should raise TgConfig::NotWritableError if config not readable" do
      ::File.stubs(:writable?).with(config_path).returns(false)

      lambda { subject.send(:check_config_file, true) }.should raise_error TgConfig::NotWritableError
    end

  end

  describe "#initialize_config_file" do
    it { should respond_to :initialize_config_file }

    it "should set @config to an empty HashWithIndifferentAccess" do
      subject.send(:instance_variable_set, :@config, nil)
      subject.send(:initialize_config_file)
      subject.send(:instance_variable_get, :@config).should == HashWithIndifferentAccess.new
    end

    it "should call :write_config_file" do
      subject.expects(:write_config_file).once

      subject.send(:initialize_config_file)
    end

  end

  describe "#parse_config_file" do
    before(:each) do
      subject.send(:instance_variable_set, :@config, nil)
    end

    it { should respond_to :parse_config_file }

    it "should parse the config file and return an instance of HashWithIndifferentAccess" do
      subject.send(:parse_config_file).should be_instance_of HashWithIndifferentAccess
    end
  end

  describe "#[]" do
    it { should respond_to :[] }

    it "should return [:pathogen] for submodules" do
      subject[:submodules].should == [:pathogen]
    end
  end

  describe "#[]=" do
    after(:each) do
      subject.send(:instance_variable_set, :@config, nil)
    end

    it { should respond_to :[]= }

    it "should set the new config in @config" do
      subject[:submodules] = [:pathogen, :github]
      subject.send(:instance_variable_get, :@config)[:submodules].should ==
        [:pathogen, :github]
    end
  end

  describe "#write_config_file" do
    before(:each) do
      subject.send(:instance_variable_set, :@config, config)
      subject.send(:instance_variable_get, :@config).stubs(:to_hash).returns(config)
    end

    it { should respond_to :write_config_file }

    it "should call to_hash on @config" do
      subject.send(:instance_variable_get, :@config).expects(:to_hash).returns(config).once

      subject.send :write_config_file
    end

    it "should call to_yaml on @config.to_hash" do
      config.expects(:to_yaml).returns(config.to_yaml).twice # => XXX: Why twice ?
      subject.send(:instance_variable_get, :@config).stubs(:to_hash).returns(config)

      subject.send :write_config_file
    end

    it "should call File.open with config_file" do
      ::File.expects(:open).with(config_path, 'w').yields(@file_handler).once

      subject.send :write_config_file
    end

    it "should write the yaml contents to the config file" do
      @file_handler.expects(:write).with(config.to_yaml).once
      ::File.stubs(:open).with(config_path, 'w').yields(@file_handler)

      subject.send :write_config_file
    end

    it "should raise TgConfig::IsEmptyError" do
      subject.send(:instance_variable_set, :@config, nil)

      lambda { subject.send :write_config_file }.should raise_error TgConfig::IsEmptyError
    end
  end

  describe "#save" do
    before(:each) do
      subject.send(:instance_variable_set, :@config, config)
      subject.send(:instance_variable_get, :@config).stubs(:to_hash).returns(config)
    end

    it { should respond_to :save }

    it "should call check_config_file to make sure it is writable" do
      TgConfig.any_instance.expects(:check_config_file).with(true).once

      subject.save
    end

    it "should call write_config_file" do
      TgConfig.any_instance.expects(:write_config_file).once

      subject.save
    end
  end
end
