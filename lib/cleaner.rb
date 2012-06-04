require 'database_cleaner'
DatabaseCleaner.strategy = :truncation
DatabaseCleaner.clean
def cleaner
  DatabaseCleaner.clean
end
