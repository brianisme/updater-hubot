# Description:
#   A command that shows us a photo of the current line at Shake Shack
#
# Commands:
#   hubot fat cam - Returns an image of the line at Shake Shack
#
# Author:
#   desmondmorris

module.exports = (robot) ->
  robot.respond /fat cam/i, (msg) ->
    msg.send 'http://www.shakeshack.com/camera.jpg'
