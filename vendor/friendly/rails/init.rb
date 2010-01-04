config = YAML.load(File.read(RAILS_ROOT + "/config/friendly.yml"))[RAILS_ENV]
Friendly.configure(config)

