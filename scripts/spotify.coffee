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
    spotify.on(ready: =>
      for playlist in spotify.playlistContainer.getPlaylists()
        @updaterPlaylist = playlist if playlist.name == 'Updater'

      unless @updaterPlaylist?
        console.log 'Cannot find Updater playlist'
        spotify.logout()
      else
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

  playNext: ->

  playPrevious: ->

  resume: spotify.player.resume
  pause: spotify.player.pause

  play: ->
    @currentTrack = @updaterPlaylist.getTrack(0)
    spotify.player.play(@currentTrack)
    album = @currentTrack.album
    console.log album.getCoverBase64()

  search: (term) ->
    search = new spotify.Search(term, 2, 10)

  getCurrentTrackInfo: (cb) ->
    return cb('No current track') unless @currentTrack?

    cb(null, 
      name: @currentTrack.name,
      artist: @currentTrack.artists[0],
      album: 
        name: album.name
        cover: 'data:image/jpeg;base64,' + album.getCoverBase64()
    )




module.exports = (robot) ->

  player = new Player
  player.init('user', 'pass', ->


    # robot.respond /spotify$/i, (msg) ->
    #   msg.send options.commands.join("\n")

    robot.respond /spotify resume/i, (msg) ->
      player.resume()

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
    robot.respond /spotify search ?(track|song|album|artist)? (.*)$/i, (msg) ->
      
      player.search()




  )

  

  options = {}
  options.commands = [
    "search <track|album|artist> <query> - Search for a track on Spotify and play it"
  ]
