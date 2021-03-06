# Install
which -s brew
if [[ $? != 0 ]] ; then
  echo "Installing Homebrew"
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi


# Update Homebrew
echo "Upgrading Homebrew"
brew update


# Install Heroku Toolbelt
which -s heroku
if [[ $? != 0 ]] ; then
  echo "Installing Heroku Toolbelt"
  brew install heroku-toolbelt
else
  echo "Upgrading  Heroku Toolbelt"
  brew upgrade heroku-toolbelt
fi



# Install Postgres
which -s psql
if [[ $? != 0 ]] ; then
  echo "Installing Postgres"
  brew install postgres
else
  echo "Upgrading  Postgres"
  brew upgrade postgres
fi

brew services start postgresql
psql postgres -tc "SELECT 1 FROM pg_database WHERE datname = 'miza'" | grep -q 1 || psql -c "CREATE DATABASE miza" 
brew services stop postgresql


# Install Redis
which -s redis-server
if [[ $? != 0 ]] ; then
  echo "Installing Redis"
  brew install redis
else
  echo "Upgrading Redis"
  brew upgrade redis
fi


# Install Mongo
which -s mongod
if [[ $? != 0 ]] ; then
  echo "Installing Mongodb"
  brew install mongodb
else
  echo "Upgrading Mongodb"
  brew upgrade mongodb
fi


# Install RabbitMQ
which -s rabbitmq-server
if [[ $? != 0 ]] ; then
  echo "Installing RabbitMQ"
  brew install rabbitmq
else
  echo "Upgrading RabbitMQ"
  brew upgrade rabbitmq
fi


# NPM Install
npm install

# Starting services
npm run services