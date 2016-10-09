###
# Bootstrap
# (sails.config.bootstrap)
#
# An asynchronous bootstrap function that runs before your Sails app gets lifted.
# This gives you an opportunity to set up your data model, run jobs, or perform some special logic.
#
# For more information on bootstrapping your app, check out:
# http://sailsjs.org/#/documentation/reference/sails.config/sails.config.bootstrap.html
###

fs = require "fs"
async = require "async"
csvProcessor = require "../process"

setupScript = "scripts/setup.sql"

argv = require("optimist")
  .alias "p", "parse"
  .alias "r", "reset-structure"
  .default "p", false
  .default "r", false
  .argv

separator = ('-' for _ in [1..50]).join ""

initDBStructure = (callback) ->
  sails.log.info separator
  sails.log.info "Init database schema".toUpperCase()
  sails.log.info separator
  fs.readFile setupScript, {encoding : "utf-8"}, (err, text) ->
    sqlCommands = text.trim().split "\n" # separate each lines
    #remove empty lines and comments
    sqlCommands = (query for query in sqlCommands when query.trim() isnt "" and query.substring(0, 2) isnt "--")
    sqlCommands = sqlCommands.join "\n"
    sqlCommands = sqlCommands.trim().split ";"
    sqlCommands.pop() #remove the last row of the array (empty string)
    async.mapSeries sqlCommands,
      (currentQuery, callback) -> #iterator function
        currentQuery = currentQuery.trim() #remove useless whitespaces
        sails.log.debug currentQuery
        DB.query currentQuery, callback
      , (error, res) -> #end function
        if error
          sails.log.error error
          process.exit(1)
        else
          sails.log.debug separator
          sails.log.debug "Schema loaded".toUpperCase()
          sails.log.debug separator
          callback()

processFile = (callback) ->
  sails.log.info separator
  sails.log.info "Filling the DB with CSV files".toUpperCase()
  sails.log.info separator
  csvProcessor (error) ->
    if error
      sails.log.error error
      process.exit(1)
    else
      callback null

module.exports.bootstrap = (cb) ->
  initTasks = []
  
  if argv['reset-structure']
    initTasks.push initDBStructure

  if argv.parse
    initTasks.push processFile
  
  async.series initTasks, cb

    

