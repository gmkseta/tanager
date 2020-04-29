SNOWDON_DB = YAML.load(ERB.new(File.read(Rails.root.join("config", "snowdon_database.yml"))).result)[Rails.env]
