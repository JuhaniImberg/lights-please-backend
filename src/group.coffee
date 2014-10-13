Base = require './base'

class Group extends Base
  constructor: (@name, @lights) ->
    super
    @size = {x: 0, y: 0, h: 0, w:0}
    min = {x: 100, y: 100}
    max = {x: 0, y: 0}
    for light in @lights
      if light.position.x < min.x
        min.x = light.position.x
      if light.position.y < min.y
        min.y = light.position.y
      if light.position.x > max.x
        max.x = light.position.x
      if light.position.y > max.y
        max.y = light.position.y
      @add_child light
    @size.x = min.x
    @size.y = min.y
    @size.w = max.x - min.x
    @size.h = max.y - min.y

  update: (lights) ->
    for light in lights
      for inlight in @lights
        if light.name == inlight.name
          inlight.update(light)

  to_json: () ->
    return {
      name: @name
      lights: (light.to_json() for light in @lights)
      size: @size
    }

module.exports = Group