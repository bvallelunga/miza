module.exports = {
  env: process.env
  isProd: process.env.NODE_ENV == "production"
  parse: require("./parse")
  redis: require("./redis")
}