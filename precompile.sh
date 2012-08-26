#!/bin/bash

mv ~/joslink/public/assetsx ~/joslink/public/assets
mv ~/joslink/config/initializers/redis.rb ~/joslink/config/initializers/redis
rake assets:precompile
mv ~/joslink/config/initializers/redis ~/joslink/config/initializers/redis.rb

