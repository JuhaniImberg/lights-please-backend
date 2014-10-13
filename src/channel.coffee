{EventEmitter} = require 'events'

class Channel extends EventEmitter
  constructor: (@id, @value) ->

  set: (val) ->
    val = Math.min(255, Math.max(0, val))
    if val != @value
      @set_smooth(0, @value, val - @value, 20)

  set_smooth: (step, start, target, steps) ->
    @value = Math.round(@smooth(step, start, target, steps))
    @emit "changed"
    if step != steps
      setTimeout(
        () =>
          @set_smooth(step+1, start, target, steps)
      , 1000/30)

  smooth: (t, b, c, d) ->
    t /= d/2
    if t < 1
      return c/2*t*t + b
    t--
    return -c/2 * (t*(t-2) - 1) + b

  get: () ->
    return @value

  to_json: () ->
    return {
      index: @id
      value: @value
      old: @value
    }

module.exports = Channel