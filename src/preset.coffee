class Preset
  constructor: (@name, @data={}) ->

  save_state: (server) ->
    @data = {groups: []}
    for group in server.groups
      @data.groups.push group.to_json()

  load_state: (server) ->
    for group in @data.groups
      for in_group in server.groups
        if group.name == in_group.name
          in_group.update group.lights if group.lights?
          in_group.active = group.active if group.active?

  to_json: ->
    return {
      name: @name
    }

module.exports = Preset