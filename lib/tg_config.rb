require "rubygems"
require "bundler/setup"

require "yaml"
require "active_support/core_ext/hash/indifferent_access"
require "tg_config/errors"
require "tg_config/version"

module TechnoGate
  class TgConfig

    attr_reader :config_file

    def initialize(config_file)
      @config_file = config_file
      check_config_file
      @config = parse_config_file
    end

    # Return a particular config variable from the parsed config file
    #
    # @param [String|Symbol] config
    # @return mixed
    # @raise [Void]
    def [](config)
      @config.send(:[], config)
    end

    # Update the config file
    #
    # @param [String] config
    # @param [Mixed] Values
    def []=(config, value)
      @config.send(:[]=, config, value)
    end

    # Save the config file
    def save
      # Make sure the config file is writable
      check_config_file(true)
      # Write the config file
      write_config_file
    end

    protected
    # Initialize the configuration file
    def initialize_config_file
      @config = HashWithIndifferentAccess.new
      write_config_file
    end

    # Check the config file
    def check_config_file(writable = false)
      # Check that config_file is defined
      raise NotDefinedError unless config_file
      # Check that the config file exists
      initialize_config_file unless ::File.exists?(config_file)
      # Check that the config file is readable?
      raise NotReadableError unless ::File.readable?(config_file)
      # Checl that the Config file is writable?
      raise NotWritableError unless ::File.writable?(config_file) if writable
    end

    # Parse the config file
    #
    # @return [HashWithIndifferentAccess] The config
    def parse_config_file
      # XXX: We should handle errors
      YAML.load_file(config_file).with_indifferent_access
    end

    # Write the config file
    def write_config_file
      raise IsEmptyError unless @config
      File.open config_file, 'w' do |f|
        f.write(@config.to_hash.to_yaml)
      end
    end
  end
end
