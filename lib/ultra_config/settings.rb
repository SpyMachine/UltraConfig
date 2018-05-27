module UltraConfig
  class Settings
    def self.default
      {
        type_safety: :weak
      }
    end

    def self.settings
      @settings ||= default
    end

    def self.set(setting, value)
      settings[setting] = value
    end

    def self.method_missing(m)
      settings[m]
    end
  end
end