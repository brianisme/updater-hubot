# Description:
#   Play Spotify using Hubot
#
# Commands:
#
# Examples:
#
spotify = require('node-spotify')(appkeyFile: './spotify_appkey.key')

module.exports = (robot) ->
  # show commands

  ready = ->
    updaterPlaylist = null
    for playlist in spotify.playlistContainer.getPlaylists()
      updaterPlaylist = playlist if playlist.name == 'Updater'

    unless updaterPlaylist?
      console.log 'Cannot find Updater playlist'
      spotify.logout()
      return

    robot.respond /spotify$/i, (msg) ->
      msg.send options.commands.join("\n")

    robot.respond /spotify (play|resume)/i, (msg) ->
      spotify.player.resume()

    robot.respond /spotify (pause|stop)$/i, (msg) ->
      # spotify.player[msg.match[1]].call(spotify.player)
      spotify.player.pause()

    robot.respond /(next|play next|play the next song)$/i, (msg) ->

    robot.respond /(previous|prev|play previous|play the previous song)$/i, (msg) ->

    robot.respond /volume ((\d{1,2})|up|down)$/i, (msg) ->


    # show what song I'm currently playing
    robot.respond /(current|song|track|current song|current track)$/i, (msg) ->

    # search through Spotify
    robot.respond /spotify search ?(track|song|album|artist)? (.*)$/i, (msg) ->
      track = updaterPlaylist.getTrack(0);
      spotify.player.play(track)





  spotify.on(ready: ready)
  spotify.login('username', 'password', false, false)

  options = {}
  options.commands = [
    "search <track|album|artist> <query> - Search for a track on Spotify and play it"
  ]



