db_config = (
  if ENV['DATABASE_URL']
    URI.parse ENV['DATABASE_URL']
  else
    db_config_hash = YAML.load(ERB.new(File.read('config/database.yml')).result)
    OpenStruct.new(db_config_hash[ENV['RACK_ENV']])
  end
)

ActiveRecord::Base.establish_connection(
  adapter: db_config.scheme == 'postgres' ? 'postgresql' : db_config.adapter,
  host: db_config.host,
  username: db_config.user,
  password: db_config.password,
  port: db_config.port,
  database: ENV['DATABASE_URL'].present? ? db_config.path[1..-1] : db_config.database,
  encoding: 'utf8'
)
