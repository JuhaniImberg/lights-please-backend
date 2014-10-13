Base = require './base'
Channel = require './channel'

class Light extends Base
  constructor: (@name, @args) ->
    super
    @type = @args.type or "spot"
    @position = @args.position or {x: 0, y: 0}
    if @args.channel?
      @channels = {"main": new Channel(@args.channel, 0)}
    else if @args.channels?
      @channels = {}
      for channel of @args.channels
        @channels[channel] = new Channel(@args.channels[channel], 0)

    for channel of @channels
      @add_child @channels[channel]

  update: (light) ->
    for channel of @channels
      @channels[channel].set light.channels[channel].value

  to_json: () ->
    channels = {}
    for channel of @channels
      channels[channel] = @channels[channel].to_json()

    return {
      name: @name
      type: @type
      channels: channels
      position: @position
    }


module.exports = Light