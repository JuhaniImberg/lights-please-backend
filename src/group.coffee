Base    = require './base'
Channel = require './channel'
Light   = require './light'

class Group extends Base
  constructor: (@data) ->
    super
    @size = @data.position
    @name = @data.name
    @lights = []
    for light in @data.lights
      @lights.push new Light light
    @active = false

  toggle: ->
    @active = !@active
    for light in @lights
      for channel_name of light.channels
        channel = light.channels[channel_name]
        channel.set 255 * @active

  update: (lights) ->
    for light in lights
      for inlight in @lights
        if light.name == inlight.name
          inlight.update(light)
    for light in @lights
      for channel_name of light.channels
        channel = light.channels[channel_name]
        if channel.value != 0
          @active = true

  to_channels: (channels) ->
    for light in @lights
      for channel_name of light.channels
        channel = light.channels[channel_name]
        channels[channel.id-1] = channel.get()

  to_json: () ->
    return {
      name: @name
      lights: (light.to_json() for light in @lights)
      size: @size
      active: @active
    }

module.exports = Group