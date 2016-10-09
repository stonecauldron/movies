module.exports =
  index : (req, res) ->
    words = req.param "s"
    DBUtils.search words, (error, results) ->
      if error
        res.serverError()
      else
        res.view "searchResults",
          results : results
          query : words
