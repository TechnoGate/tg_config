module TechnoGate
  class TgConfig
    TgConfigError = Class.new Exception

    NotReadableError = Class.new TgConfigError
    NotDefinedError = Class.new TgConfigError
    NotWritableError = Class.new TgConfigError
    NotValidError = Class.new TgConfigError
    IsEmptyError = Class.new TgConfigError
    ConfigFileNotSetError = Class.new TgConfigError
  end
end
