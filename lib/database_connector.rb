require 'mysql2'
require 'psych' # For parsing YAML

class DatabaseConnector
  @@client = nil

  def self.connect(environment='development')
    config = File.expand_path('../../config/database.yml', __FILE__)
    all_configs=Psych.load_file(config)
    db_config=all_configs[environment.to_s]

    if db_config.nil?
      raise ArgumentError, "Invalid environment: #{environment}"
    end

    if(@@client.nil? || @@client.closed?)
      puts "Connecting to database..." #{environment}"
      @@client = Mysql2::Client.new(
        host: db_config['host'],
        username: db_config['username'],
        password: db_config['password'],
        database: db_config['database'],
        encoding: db_config['encoding'] || 'utf8mb4'
      )
      puts "Connection established to #{db_config['database']}"
    else
      puts "Reusing existing connection to #{db_config['database']}"
    end
    @@client
  rescue Mysql2::Error => e
    puts "Error connecting to database: #{e.message}"
    raise
  end

  def self.client
    @@client
  end
  def self.close
    if @@client && !@@client.closed?
      puts "Closing connection to database..."
      @@client.close
      @@client = nil
    end
  end
end