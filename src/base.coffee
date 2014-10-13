{EventEmitter} = require 'events'

class Base extends EventEmitter
  constructor: () ->
    @children = []

  add_child: (child) ->
    if child == @
      return
    @children.push(child)
    child.on "changed", () =>
      @emit "changed"

module.exports = Base