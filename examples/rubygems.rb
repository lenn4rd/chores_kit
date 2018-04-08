require 'net/http'

Chores.define :rubygems do
  schedule at: '2018-03-12', every: 1.week

  task :download do
    uri = URI('https://s3-us-west-2.amazonaws.com/rubygems-dumps/?prefix=production/public_postgresql')
    index = Net::HTTP.get(uri)

    matches = index.match(/.*<Key>(.*)<\/Key>.*/)
    filename = matches.captures.first
    url = "https://s3-us-west-2.amazonaws.com/rubygems-dumps/#{filename}"

    sh "curl -o rubygems.tar -L #{url}"
  end

  task :drop_db do
    sh 'dropdb -U postgres --if-exists rubygems'
  end

  task :create_db do
    sh 'createdb -U postgres rubygems'
  end

  task :create_extension do
    sh 'psql -q -U postgres -d rubygems -c "CREATE EXTENSION IF NOT EXISTS hstore;"'
  end

  task :unpack do
    sh 'tar xOf rubygems.tar public_postgresql/databases/PostgreSQL.sql.gz | gunzip > rubygems.sql'
  end

  task :load do
    sh 'psql -U postgres -d rubygems < rubygems.sql'
  end

  run :download, triggers: :drop_db
  run :drop_db, triggers: :create_db
  run :create_db, triggers: :create_extension
  run :create_extension, triggers: :unpack
  run :unpack, triggers: :load
end
