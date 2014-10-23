# Description:
#   Play Spotify using Hubot
#
# Commands:
#
# Examples:
#
sh = require('sh')
spotify = require('node-spotify')(appkeyFile: './spotify_appkey.key')

displayTrack = (track) ->
  "#{track.artists[0].name} - #{track.name}"

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
    if @currentIdx >= @updaterPlaylist.numTracks - 1
      @currentIdx = @updaterPlaylist.numTracks - 1
      return
    @currentIdx++
    @play()

  playPrevious: ->
    if @currentIdx <= 0
      @currentIdx = 0
      return
    @currentIdx--
    @play()

  resume: spotify.player.resume
  pause: spotify.player.pause

  addTrack: (track, buttIn=false) ->
    if @updaterPlaylist.numTracks > 0
      idx = if buttIn then (@currentIdx + 1) else @updaterPlaylist.numTracks
    else
      idx = 0
    track = spotify.createFromLink(track)

    return unless track?
    @updaterPlaylist.addTracks([track], idx)

  getPlaylistTracks: ->
    @updaterPlaylist.getTracks()

  play: (track) ->
    @currentTrack = if track? then spotify.createFromLink(track) else @updaterPlaylist.getTrack(@currentIdx)
    console.log "playing #{displayTrack(@currentTrack)}"
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

  player.init('user', 'password', ->

    # @todo programtic prefix
    # robot.respond /spotify$/i, (msg) ->
    #   msg.send options.commands.join("\n")

    robot.respond /spotify resume/i, (msg) ->
      player.resume()

    robot.respond /spotify (play|add) (.*)/i, (msg) ->
      console.log "#{msg.match[1]}ing #{msg.match[2]}"
      player.addTrack(msg.match[2], msg.match[1] == 'play')
      player.playNext() if msg.match[1] == 'play'

    robot.respond /spotify play$/i, (msg) ->
      console.log 'playing'
      player.play()

    robot.respond /spotify (pause|stop)$/i, (msg) ->
      player.pause()

    robot.respond /spotify show playlist/i, (msg) ->
      reply = ""
      for track, idx in player.getPlaylistTracks()
        indicator = if player.currentIdx == idx then ':musical_note: ' else ''
        reply += "\n#{indicator} #{displayTrack(track)}\n"

      msg.reply reply

    robot.respond /(next|play next|play the next song)$/i, (msg) ->
      console.log 'playing next'
      player.playNext()

    robot.respond /(previous|prev|play previous|play the previous song)$/i, (msg) ->
      console.log 'playing previous'
      player.playPrevious()

    robot.respond /spotify volume ((\d{1,2})|up|down|mute)$/i, (msg) ->
      switch
        when msg.match[1] == 'up' then player.louder()
        when msg.match[1] == 'down' then player.quieter()
        when msg.match[1] == 'mute' then player.mute()
        else player.setVolume(msg.match[1])

    # @todo not working
    # robot.respond /(current|song|track|current song|current track)$/i, (msg) ->
    #   player.getCurrentTrackInfo (err, info) ->
    #     console.log info.artist.name
    #     console.log info.name
    #     console.log info.album.name
    #     console.log info.album.cover

    # search through Spotify
    # robot.respond /spotify search ?(track|song|album|artist)? (.*)$/i, (msg) ->
    robot.respond /spotify search (.*)$/i, (msg) ->

      player.search msg.match[1], (err, results) ->
        reply = ''
        for track in results
          reply += "\n
          ============================================================\n
          #{displayTrack(track)}\n
          hubot spotify <play|add> #{track.link}\n
          ============================================================"

        msg.reply reply

  )

  options = {}
  options.commands = [
    "search <track|album|artist> <query> - Search for a track on Spotify and play it"
  ]
