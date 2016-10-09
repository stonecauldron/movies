async = require "async"

handlers =
  Company : (res, result) ->
    id = result.coid
    name = result.name
    delete result.name
    DBUtils.findFilmsFromCompany id, (error, films) ->
      res.view "recordDetails/company",
        name : name
        attributes : result
        films : films
  Person : (res, result) ->
    id = result.pid
    async.parallel [
      (cb) -> DBUtils.findFilmsFromPerson id, cb
      (cb) -> DBUtils.findPersonaFromPerson id, cb
    ], (error, [films, persona]) ->
      if error
        sails.log.error error
        res.serverError()
      else
        res.view "recordDetails/person",
          name : "#{result.first_name}, #{result.last_name}"
          attributes : result
          films : films
          persona : persona
  Production : (res, result) ->
    id = result.prodid
    name = result.title
    delete result.title
    async.parallel [
        (cb) -> DBUtils.findActorsInProduction id, cb
        (cb) -> DBUtils.findCrewInProduction id, cb
    ], (error, [actors, people]) ->
      res.view "recordDetails/production",
        name : name
        attributes : result
        actors : actors
        people : people
  Persona : (res, result) ->
    name = result.name
    delete result.name
    res.view "recordDetails/generic",
      name : name
      attributes : result
    
module.exports = {}

for own tableName, handler of handlers
  do (tableName, handler) ->
    module.exports[tableName] = (req, res) ->
      id = parseInt req.param("id")
      if isNaN id
        res.badRequest()
      else
        DBUtils.findRecord tableName, id, (error, result) ->
          if error
            res.serverError()
          else
            if result.length is 0
              res.notFound()
            else
              result = result[0]
              handler(res, result)
