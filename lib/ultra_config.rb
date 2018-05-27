require_relative 'ultra_config/namespace'

module UltraConfig
  def self.define(&block)
    Namespace.new(&block)
  end
end
