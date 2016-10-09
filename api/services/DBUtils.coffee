async = require "async"

tableToPrimary =
  Person : "pid"
  PersonAltName : "altid"
  Production : "prodid"
  ProductionAltName : "altid"
  Company : "coid"
  Persona : "charid"

module.exports =
  findRecord : (table, id, callback) ->
    if tableToPrimary[table]?
      query = "SELECT * FROM #{table} WHERE #{tableToPrimary[table]} = ?"
      DB.query query, [id], callback
    else
      callback "UnkownTable"
  
  findFilmsFromCompany : (coid, callback) ->
    query = "SELECT DISTINCT Production.* FROM CompanyContributesProduction as CCP \
    JOIN Production ON Production.prodid = CCP.prodid AND CCP.coid = ? AND Production.kind NOT LIKE 'episode'"
    DB.query query, [coid], callback
  
  findFilmsFromPerson : (pid, callback) ->
    query = "SELECT DISTINCT Production.* FROM PersonParticipatesProduction as PPP \
    JOIN Production ON Production.prodid = PPP.prodid AND PPP.pid = ? AND Production.kind NOT LIKE 'episode'"
    DB.query query, [pid], callback

  findPersonaFromPerson : (pid, callback) ->
    query = "SELECT DISTINCT Persona.* FROM PersonParticipatesProduction as PPP \
    JOIN Production ON Production.prodid = PPP.prodid \
    JOIN Persona ON Persona.charid = PPP.charid AND Production.kind NOT LIKE 'episode' AND PPP.pid = ?"
    DB.query query, [pid], callback
  
  findActorsInProduction : (prodid, callback) ->
    query = "SELECT DISTINCT Person.pid, Person.first_name, Person.last_name, P.name as plays, P.charid \
    FROM PersonParticipatesProduction as PPP \
    JOIN Persona as P on P.charid = PPP.charid \
    JOIN Person ON Person.pid = PPP.pid \
    WHERE role IN ('actor', 'actress') AND PPP.prodid = ?"
    DB.query query, [prodid], callback

  findCrewInProduction : (prodid, callback) ->
    query = "SELECT DISTINCT Person.pid, Person.first_name, Person.last_name, PPP.role \
    FROM PersonParticipatesProduction as PPP \
    JOIN Person ON Person.pid = PPP.pid \
    WHERE role NOT IN ('actor', 'actress') AND PPP.prodid = ?"
    DB.query query, [prodid], callback

  search : (text, callback) ->
    toSearch = [
      ["Company", "name"]
      ["Person", "first_name"]
      ["Person", "last_name"]
      ["Persona", "name"]
      ["Production", "title"]
    ]

    async.map toSearch, ([tableName, column], callback) ->
      DB.query "SELECT * FROM #{tableName} WHERE #{column} LIKE ?", ["%#{text}%"], (error, result) ->
        if error
          callback error
        else
          callback null, [result, tableName]
    , (error, results) ->
      if error
        callback error
      else
        result = _.chain(results)
          .groupBy ([result, tableName]) -> tableName
          .mapValues (values) ->
            _.flatten(_.map(values, (v) -> v[0]))
          .value()
        callback null, result





