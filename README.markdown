# Notes to Self (To be included somewhere)

* Config.ru is broken under Ruby 1.9.2 (require path issue), so far sticking to 1.9.2

# Setup

# Install the required gems 
    $ bundle install

# Configure

    $ cp config.sample.rb config.rb
    
And edit `config.rb` to fit your enviroment.

# Prepare the database

Start a **irb** console with your environment loaded and migrate. **IMPORTANT**:
DataMapper migrations are *destructive* so this procedure will wipe all data in
the database:

    $ irb -r dashboard.rb
    > require  'dm-migrations'
    > DataMapper.auto_migrate!

