#
#
# Description:
#
#
# Commands:
#
sh = require('sh')

module.exports = (robot) ->

  robot.respond /get (on|off) (.*)/i, (msg) ->
    console.log "getting #{msg.match[1]} #{msg.match[2]}"
    if msg.match[1] is 'on'
      sh("./scripts/airplay.sh 'Happy Willown'")
    else if msg.match[1] is 'off'
      sh("./scripts/airplay.sh Headphones")
