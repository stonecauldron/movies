fs = require "fs"
msql = require "mysql"
c = require "./config/local.js"
async = require "async"

parse = (callback) ->
  DB = msql.createConnection c.connections.defaultAdapter
  class FileAnaylser
    buffer : []
    bufferedLine : ""
    sending : 0
    linesParsed : 0
    percentage : 0
    done : false
    constructor : (@fileHandler,@callback, @bufferSize = 1, @queriesInParallel = 1000,
        @reductionFactor = 0.5, @diffEcho = 100000) ->
      @stream = fs.createReadStream @fileHandler.path,
        encoding : 'utf-8'
      @stream.on 'data', (text) =>
        @bufferedLine += text
        @processBufferedLine()
      @stream.on 'end', () =>
        @processBufferedLine true
        @done = true
    sendQuery : (query) =>
      DB.query query, (error) =>
        if error
          sails.log.error error
        @sending--
        if not @done and @sending < @queriesInParallel*@reductionFactor and @stream.isPaused()
          sails.log.debug "we resume reading the file"
          @stream.resume()
        if @done is true and @sending is 0 and @bufferedLine.length is 0 and @buffer.length is 0
          @callback()
    processBufferedLine : (force = false) =>
      lines = @bufferedLine.split "\n"
      if lines.length > 1
        @bufferedLine = lines.pop()
        lines = lines.map (line) ->
          cols = line.split "\t"
          cols.map (element) -> if element is "\\N" then null else element
        @buffer = @buffer.concat lines
      if @buffer.length >= @bufferSize or force is true
        @linesParsed += @buffer.length
        oldPercentage = @percentage
        @percentage = Math.floor @linesParsed/@fileHandler.size*100
        if oldPercentage isnt @percentage
          sails.log.info "Progression (#{@fileHandler.name}) = #{@percentage}%"
        if @buffer.length > 0
          query = @fileHandler.processBuffer @buffer
          @buffer = []
          if query.length > 0
            @sending++
            if @sending > @queriesInParallel
              sails.log.debug("Too much queries in parallel we pause")
              @stream.pause()
            @sendQuery(query)
  class CompanyHandler
    name : "Company"
    path : "datasets/COMPANY.csv"
    size : 279142
    processBuffer : (buffer) ->
      buffer = buffer.map (line) ->
        [id, country_code, name] = line
        country_code = country_code.substring 1, (country_code.length-1) if country_code
        "(#{id}, #{DB.escape country_code}, #{DB.escape name})"
      endQuery = buffer.join ", "
      "INSERT INTO Company (coid, country_code, name) VALUES " + endQuery

  class ProductionHandler
    name : "Production"
    path : "datasets/PRODUCTION.csv"
    size : 3180098
    processBuffer : (buffer) ->
      buffer = buffer.map (line) ->
        [id, title, year, seriesid, seasonnum, epnum, range, kind, genre] = line
        if range isnt null and range isnt "????"
          range = range.split '-'
          [beginyear, endyear] = range
          endyear = if endyear is "????" then null else endyear
        else
          beginyear = null
          endyear = null
        "(#{id}, #{DB.escape title.substring 0, 255}, #{year}, #{seriesid}, #{seasonnum}, #{epnum},
            #{beginyear}, #{endyear}, #{DB.escape kind}, #{DB.escape genre})"
      values = buffer.join ", "
      "INSERT INTO Production (prodid, title, year, seriesid, seasonnum,\
      epnum, beginyear, endyear, kind, genre) VALUES " + values

  class ProductionAltNameHandler
    name : "ProductionAlternativeName"
    path : "datasets/ALTERNATIVE_TITLE.csv"
    size : 407441
    processBuffer : (buffer) ->
      buffer = buffer.map (line) ->
        [id, prod_id, title] = line
        "(#{id}, #{prod_id}, #{DB.escape title.substring 0, 255})"
      values = buffer.join ", "
      "INSERT INTO ProductionAltName (altid, prodid, title) VALUES " + values

  class PersonAltNameHandler
    name : "PersonAlternativeName"
    path : "datasets/ALTERNATIVE_NAME.csv"
    size : 869697
    processBuffer : (buffer) ->
      buffer = buffer.map (line) ->
        "(#{(line.map DB.escape.bind DB).join ", "})"
      endQuery = buffer.join ", "
      "INSERT INTO PersonAltName (altid, pid, name) VALUES " + endQuery

  class PersonHandler
    name : "Person"
    path : "datasets/PERSON.csv"
    size : 4857852
    nameParse : (name) ->
      names = name.split ","
      last_name = names.shift()
      first_name = names.join ", "
      [first_name.trim(), last_name.trim()]
    dateParse : (date) ->
      if date
        parsed = new Date Date.parse(date)
        if isNaN parsed.getTime()
          parsed = null
        parsed
      else
        null
    processBuffer : (buffer) =>
      buffer = buffer.map (line) =>
        [id, names, gender, trivia, quotes, birthDate, deathDate, birthName, biography, spouse, height] = line
        [first_name, last_name] = @nameParse names
        gender = if gender is 'm' then 1 else 0
        oldbd = birthDate
        birthDate = @dateParse birthDate
        deathDate = @dateParse deathDate
        normalizedHeight = 'NULL'
        if spouse isnt null
          if spouse[0] is "'"
            spouse = spouse.substring 1
            sepIndex = spouse.indexOf "'"
            spouse = spouse.substring 0, sepIndex
          sepIndex = spouse.indexOf "("
          if sepIndex isnt -1
            spouse = spouse.substring 0, sepIndex
          spouse = spouse.trim()
          if spouse is "" or spouse is "?" or spouse is "Unmarried"
            spouse = null
          else
            spouseNameParts = spouse.split " "
            if spouseNameParts.length > 1
              spouse_first_name = spouseNameParts.shift()
              spouse_last_name = spouseNameParts.join(" ")
            else
              spouse_first_name = null
              spouse_first_name = spouse
        if height
          normalizedHeight = -1
          rawHeight = height
          sep1 = height.indexOf "'"
          if sep1 isnt -1
            height = height.replace /\([cm0-9 ]*\)/, ""
            feet = parseInt (height.substring(0, sep1)).trim()
            inches = 0
            remainder = height.substring(sep1+1).trim()
            if remainder isnt ""
              remainderParts = remainder.split " "
              remainderParts.forEach (part) ->
                sep4 = part.indexOf '/'
                if sep4 isnt -1
                  inches += 1.0 / parseInt(part.substring(sep4 + 1).replace('"', '').trim())
                else if part.indexOf '"' isnt -1
                  inches += parseInt part.replace('"', '').trim()
                else
                  sails.log.error "Impossible to parse height : " + height
            inches += feet * 12
            normalizedHeight = 2.54 * inches
          else
            normalizedHeight = parseFloat height.replace("cm", "").replace(",", ".").trim()
        "(#{id}, #{DB.escape first_name}, #{DB.escape last_name}, #{gender}, #{DB.escape trivia},
            #{DB.escape quotes}, #{DB.escape birthDate}, #{DB.escape deathDate}, #{DB.escape birthName},
            #{DB.escape biography}, #{DB.escape spouse}, #{normalizedHeight})"
      endQuery = buffer.join ", "
      beginQuery = "INSERT INTO Person (pid, first_name, last_name, gender, trivia, quotes, birth_date, \
        death_date, birth_name, bio, spouse, height) VALUES "
      beginQuery + endQuery

  class CharacterHandler
    name : "Character"
    path : "datasets/CHARACTER.csv"
    size : 3589274
    processBuffer : (buffer) ->
      buffer = buffer.map (line) ->
        [charid, name] = line
        "(#{charid}, #{DB.escape name.substring 0, 100})"
      endQuery = buffer.join ", "
      "INSERT INTO Persona (charid, name) VALUES " + endQuery

  class ProdCastHandler
    name : "ProductionCast"
    path : "datasets/PRODUCTION_CAST.csv"
    size : 44046417
    processBuffer : (buffer) ->
      buffer = buffer.map (line) -> "(#{(line.map DB.escape.bind(DB)).join(", ")})"
      buffer = buffer.join ", "
      "INSERT INTO PersonParticipatesProduction (prodid, pid, charid, role) VALUES #{buffer}"

  class ProdCompanyHandler
    name : "ProductionCompany"
    path : "datasets/PRODUCTION_COMPANY.csv"
    size : 3407851
    processBuffer : (buffer) ->
      buffer = buffer.map (line) ->
        [id, coid, prodid, role] = line
        "(#{prodid}, #{coid}, #{DB.escape role})"
      endQuery = buffer.join ", "
      "INSERT IGNORE INTO CompanyContributesProduction (prodid, coid, role) VALUES " + endQuery

  handlers = [
    CompanyHandler
    ProductionHandler
    ProductionAltNameHandler
    PersonHandler
    PersonAltNameHandler
    CharacterHandler
    ProdCastHandler
    ProdCompanyHandler
  ]

  async.eachSeries handlers, (handlerConstructor, callback) ->
    handler = new handlerConstructor()
    sails.log.debug "Start feeding " + handler.name
    new FileAnaylser handler, callback
  , (error) ->
    DB.end () ->
      sails.log.debug "DB connexion closed"
      callback error
    

module.exports = parse
