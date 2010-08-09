module Config
  def self.settings
    @settings ||= YAML.load(File.read(File.join(File.dirname(File.dirname(__FILE__)), 'config', 'authentication.yml')))
  end

  def self.[](key)
    settings[key]
  end
end
