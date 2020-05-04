class DatabaseController < ApplicationController
# POST /migrate
  timeout 1200
  def migrate
    env = ENV['JETS_ENV'] || 'development'
    logger = Logger.new(STDOUT)
    logger.info("start to migrate db. env: #{env}")
    ActiveRecord::Base.logger = logger
    config = Jets.application.config.database[env]
    logger.debug(config)

    create(config)

    migrations_path = File.join(File.dirname(__FILE__ ), '../../db/migrate')

    connection = connect(config)
    logger.info("established connection. #{connection}")

    schema_migration = ActiveRecord::Base.connection.schema_migration
    schema_migration.create_table
    context =  ActiveRecord::MigrationContext.new([migrations_path], schema_migration)
    migrations = context.migrations
    # version = ENV["VERSION"] .present? ? ENV["VERSION"].to_i : migrations.max_by(&:version).version
    version = ENV["VERSION"] .present? ? ENV["VERSION"].to_i : ActiveRecord::Migrator.current_version

    logger.info("migration current version = #{version}")
    logger.info(migrations)

    ActiveRecord::Migrator.new(:up, migrations, schema_migration, version).migrate

    render json: { result:"success" }
  end

  private

  def connect(config)
    ActiveSupport.on_load(:active_record) do
      ::ActiveRecord::Base.establish_connection(config)
    end
  end

  def create(config)
    database = ActiveRecord::Tasks::MySQLDatabaseTasks.new(config)
    database.create
    puts 'Database created!'
  rescue ActiveRecord::Tasks::DatabaseAlreadyExists => error
    # do nothing
    puts "Database #{config['database']} already exists"
  end

  def load_data
    if %(development).include? Jets.env
      load(Jets.root.join("db", "seeds.rb"))
      render json: { result:"success" }
    end
  end

  #delete all records from DB
  def delete
    if %(development).include? Jets.env
      tables = []
      ActiveRecord::Base.connection.execute("show tables").each { |r| tables << r[0] }
      tables = tables - ["schema_migrations"]
      tables.each do |table|
        ActiveRecord::Base.connection.execute("set foreign_key_checks = 0;")
        ActiveRecord::Base.connection.execute("truncate #{table}")
        ActiveRecord::Base.connection.execute("set foreign_key_checks = 1;")
      end
      render json: { result:"success" }
    end
  end
end
