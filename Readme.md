# Installation
The installation process will install `Homebrew` and is
intended to run only on a Mac.
``` bash
git clone git@github.com:bvallelunga/miza.git
npm run local-setup 
```


# Running server
``` bash
# Run all servers
heroku local

# Run specific server
heroku local web
heroku local workers
heroku local tracking_worker
```


# Activating Services & Databases
After rebooting your computer, services like 
Redis or Postgres may not be running. Use this
command to activate them.

``` bash
npm run services
```


# Quick Push To Production
Sometimes we will need to push quickly to 
production without submitting a pull request.
Use this command to quickly push to production. It
will take up to 5 minutes for the web workers to show
the changes.

``` bash
npm run prod-deploy
```