require "active_support/core_ext/hash/indifferent_access"
require "tg_config/errors"
require "tg_config/version"

module TechnoGate
  module TgConfig
    extend self

    # Define the config class variable
    @@config = nil

    # Define the config file
    @@config_file = nil

    # Return a particular config variable from the parsed config file
    #
    # @param [String|Symbol] config
    # @return mixed
    # @raise [Void]
    def [](config)
      if @@config.nil?
        check_config_file
        @@config ||= parse_config_file
      end

      @@config.send(:[], config)
    end

    # Update the config file
    #
    # @param [String] config
    # @param [Mixed] Values
    def []=(config, value)
      if @@config.nil?
        check_config_file
        @@config ||= parse_config_file
      end

      @@config.send(:[]=, config, value)
    end

    # Get the config file
    #
    # @return [String] Absolute path to the config file
    def config_file
      raise ConfigFileNotSetError unless @@config_file

      @@config_file
    end

    # Set the config file
    #
    # @param [String] Absolute path to the config file
    def config_file=(config_file)
      @@config_file = config_file
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
      File.open(config_file, 'w') do |f|
        f.write ""
      end
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
      begin
        parsed_yaml = YAML.parse_file config_file
      rescue Psych::SyntaxError => e
        raise NotValidError,
          "Not valid YAML file: #{e.message}."
      end
      raise NotValidError,
        "Not valid YAML file: The YAML does not respond_to to_ruby." unless parsed_yaml.respond_to?(:to_ruby)

      parsed_yaml.to_ruby.with_indifferent_access
    end

    # Write the config file
    def write_config_file
      raise IsEmptyError unless @@config
      File.open config_file, 'w' do |f|
        f.write(@@config.to_hash.to_yaml)
      end
    end
  end
end
