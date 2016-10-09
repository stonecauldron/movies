module.exports =
  index: (req, res) ->
    res.view "query",
      text: ''
      url: '/query/send'
      data: []
      error: null

  send: (req, res) ->
    query = req.body.request
    DB.query query, (error, result) ->
      if error
        res.view "query",
          text: query
          url: '/query/send'
          data: []
          error: error
      else
        res.view "query",
          text: query
          url: '/query/send'
          data: result
          error: null
