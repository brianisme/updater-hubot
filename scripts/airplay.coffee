#
#
# Description:
#
#
# Commands:
#
sh = require('sh')

module.exports = (robot) ->
  robot.respond /get (on|off) the speakers/i, (msg) ->
  # robot.respond /get (on|off) (.*)/i, (msg) ->
    console.log "getting #{msg.match[1]} the speakers"
    if msg.match[1] is 'on'
      sh('sh ./scripts/airplay.sh "Happy Willow"')
      # sh("./scripts/sudoer.sh username password 'Happy Willown'")
    else if msg.match[1] is 'off'
      sh('sh ./scripts/airplay.sh "Internal Speakers"')
      # sh("./scripts/sudoer.sh username password 'Internal Speakers'")
