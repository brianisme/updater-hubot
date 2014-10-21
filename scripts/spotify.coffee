# Description:
#   Play Spotify using Hubot
#
# Commands:
#
# Examples:
#
sh = require('sh')
spotify = require('node-spotify')(appkeyFile: './spotify_appkey.key')

class Player
  init: (username, password, cb) ->
    @volume = 50
    @currentIdx = 0

    spotify.on(ready: =>
      for playlist in spotify.playlistContainer.getPlaylists()
        @updaterPlaylist = playlist if playlist.name == 'Updater'

      unless @updaterPlaylist?
        console.log 'Cannot find Updater playlist'
        spotify.logout()
      else
        spotify.player.on(endOfTrack: @playNext)
        cb()
    )
    spotify.login(username, password, false, false)

  louder: ->
    @setVolume(@volume + 10)

  quieter: ->
    @setVolume(@volume - 10)

  mute: ->
    @setVolume(0)

  setVolume: (volume) ->
    @volume = volume
    @volume = 0 if volume < 0
    @volume = 100 if volume > 100
    sh("osascript -e 'set volume output volume #{@volume}'")

  playNext: =>
    @currentIdx++
    @play()

  playPrevious: ->

  resume: spotify.player.resume
  pause: spotify.player.pause

  play: (track) ->
    @currentTrack = if track? then spotify.createFromLink(track) else @updaterPlaylist.getTrack(@currentIdx)
    spotify.player.play(@currentTrack)

  search: (term, cb) ->
    search = new spotify.Search(term, 0, 5)
    search.execute( (err, result) ->
      cb(err) if err?
      cb(null, result.tracks)
    )

  getTrackInfo: (track)->
    return unless track?

    {
      name: track.name,
      artist: track.artists[0].name,
      album: track.album.name
    }




module.exports = (robot) ->

  player = new Player
  player.init('user', 'pass', ->


    # robot.respond /spotify$/i, (msg) ->
    #   msg.send options.commands.join("\n")

    robot.respond /spotify resume/i, (msg) ->
      player.resume()

    robot.respond /spotify play (.*)/i, (msg) ->
      player.play(msg.match[1])

    robot.respond /spotify play/i, (msg) ->
      player.play()

    robot.respond /spotify (pause|stop)$/i, (msg) ->
      # spotify.player[msg.match[1]].call(spotify.player)
      player.pause()

    robot.respond /(next|play next|play the next song)$/i, (msg) ->

    robot.respond /(previous|prev|play previous|play the previous song)$/i, (msg) ->

    robot.respond /spotify volume ((\d{1,2})|up|down|mute)$/i, (msg) ->
      switch
        when msg.match[1] == 'up' then player.louder()
        when msg.match[1] == 'down' then player.quieter()
        when msg.match[1] == 'mute' then player.mute()
        else player.setVolume(msg.match[1])

    # show what song I'm currently playing
    robot.respond /(current|song|track|current song|current track)$/i, (msg) ->
      player.getCurrentTrackInfo (err, info) ->
        console.log info.artist.name
        console.log info.name
        console.log info.album.name
        console.log info.album.cover



    # search through Spotify
    # robot.respond /spotify search ?(track|song|album|artist)? (.*)$/i, (msg) ->
    robot.respond /spotify search (.*)$/i, (msg) ->

      player.search msg.match[1], (err, results) ->
        for track in results
          msg.reply "#{track.artists[0].name} - #{track.name} \n hubot spotify play #{track.link}"


  )



  options = {}
  options.commands = [
    "search <track|album|artist> <query> - Search for a track on Spotify and play it"
  ]
