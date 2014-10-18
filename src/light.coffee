Base    = require './base'
Channel = require './channel'

class Light extends Base
  constructor: (@data) ->
    super
    @name = @data.name or "unnamed light"
    @type = @data.type or "spot"
    @position = @data.position or {x: 0, y: 0}

    if @data.channel?
      @channels = {"main": new Channel(@data.channel, 0)}
    else if @data.channels?
      @channels = {}
      for channel of @data.channels
        @channels[channel] = new Channel(@data.channels[channel], 0)

    @active = false

    for channel of @channels
      @add_child @channels[channel]

  update: (light) ->
    @active = false
    if not light.channels? then return false
    for channel of @channels
      if @channels[channel].set(light.channels[channel].value)
        if light.channels[channel].value != 0
          @active = true
    return @active

  to_json: () ->
    channels = {}
    for channel of @channels
      channels[channel] = @channels[channel].to_json()

    return {
      name: @name
      type: @type
      channels: channels
      position: @position
      type: @type
    }


module.exports = Light