request = require('request')

class EchoNest
  baseUri = 'http://developer.echonest.com/api/v4'
  en = (endpoint, payload, cb) ->
    request(
      useQuerystring: true
      method: 'get'
      uri: "#{baseUri}/#{endpoint}"
      qs: payload
      , cb
    )

  constructor: (key) ->
    @key = key

  getTrackId: (artist, track, cb) ->
    en('song/search',
      api_key: @key
      artist: artist
      title: track
      format: 'json'
      results: 1
    , cb)

  getTrackById: (id, cb) =>
    en('playlist/static',
      api_key: @key
      song_id: id
      type: 'song-radio'
      bucket: ['id:spotify', 'tracks']
      format: 'json'
      results: 2
      variety: 1
      adventurousness: 0.8
      distribution: 'wandering'
      limit: true
    , cb)

  # getTrackByTrack: (artist, track, cb) =>
  #   @getTrackId artist, track, (error, response, body) =>
  #     try
  #       id = JSON.parse(body).response.songs[0].id
  #     catch e
  #      return cb("EchoNest: Cannot get track id - #{body}")

  #     console.log "Searching similar for: #{artist} - #{track} (#{id})"
  #     en('playlist/static',
  #       api_key: @key
  #       song_id: id
  #       type: 'song-radio'
  #       bucket: ['id:spotify', 'tracks']
  #       format: 'json'
  #       results: 2
  #       variety: 1
  #       adventurousness: 0.8
  #       distribution: 'wandering'
  #       limit: true
  #     , cb)
