module TechnoGate
  class TgConfig
    MAJOR = 0
    MINOR = 1
    TINY = 3
    PRE = ''

    def self.version
      # Init the version
      version = [MAJOR, MINOR, TINY]
      # Add the pre if available
      version << PRE unless PRE.nil? || PRE !~ /\S/
      # Return the version joined by a dot
      version.join('.')
    end
  end
end
