# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "byebug"
require "active_list"

require "minitest/autorun"

db_config = YAML.load_file(File.expand_path("database.yml", __dir__)).fetch(ENV["DB"] || "sqlite")
ActiveRecord::Base.establish_connection(db_config)
ActiveRecord::Schema.verbose = false

def teardown_db
  ActiveRecord::Base.connection.data_sources.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end

def setup_db
  # sqlite cannot drop/rename/alter columns and add constraints after table creation
  sqlite = ENV.fetch("DB", "sqlite") == "sqlite"

  # AR caches columns options like defaults etc. Clear them!
  ActiveRecord::Base.connection.create_table :mixins do |t|
    t.column :position, :integer unless sqlite
    t.column :active, :boolean, default: true
    t.column :parent_id, :integer
    t.column :parent_type, :string
    t.column :created_at, :datetime
    t.column :updated_at, :datetime
    t.column :state, :integer
  end

  # TODO: uncomment this line after_create hook is implemented
  # ActiveRecord::Base.connection.add_index :mixins, :position, unique: true unless sqlite

  if sqlite
    # SQLite cannot add constraint after table creation, also cannot add unique inside ADD COLUMN
    ActiveRecord::Base.connection.execute("ALTER TABLE mixins ADD COLUMN position integer8 NOT NULL CHECK (position > 0) DEFAULT 1")
    # TODO: uncomment this line after_create hook is implemented
    # ActiveRecord::Base.connection.execute("CREATE UNIQUE INDEX index_mixins_on_pos ON mixins(position)")
  else
    ActiveRecord::Base.connection.execute("ALTER TABLE mixins ADD CONSTRAINT pos_check CHECK (position > 0)")
  end

  ActiveRecord::Base.connection.schema_cache.clear!
end
