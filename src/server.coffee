http = require 'http'
SocketIO = require 'socket.io'

request = require 'request'

Channel = require './channel'
Light = require './light'
Group = require './group'
Base = require './base'

class Server extends Base
  constructor: (@config) ->
    super
    @dirty = false
    @sock = http.createServer()
    @server = new SocketIO(@sock)
    @sock.listen @config.general.port, () =>
      console.log "Listening on #{@config.general.port}"

    @groups = []
    for group of @config.groups
      clights = @config.groups[group]
      lights = (new Light(name, clights[name]) for name of clights)
      gro = new Group group, lights
      @groups.push gro
      gro.on "changed", () =>
        @dirty = true


    @interval = setInterval( () =>
      @check_dirty()
    ,1000 / @config.general.update_hz)

    @server.on "connection", (socket) =>
      process.stdout.write "C"
      @send_ws()

      socket.on "update", (data) =>
        # console.log data
        process.stdout.write "I"
        for group in data.groups
          for ingroup in @groups
            if group.name == ingroup.name
              ingroup.update(group.lights)

  check_dirty: () ->
    if @dirty
      @send_ws()
      @send_ola()
      process.stdout.write "O"
      @dirty = false

  send_ola: ->
    if @config.ola.mock then return
    channels = (0 for i in [0..512])
    for group in @groups
      group.to_channels channels
    data = {
      form: {
        d: channels.join ","
        u: @config.ola.universe
      }
    }
    request.post @config.ola.host + "set_dmx", data, (error, response, b) ->
      if error
        process.stdout.write "\nOLA error\n"
        console.log error
        console.log response


  send_ws: () ->
    @server.emit "update", {groups: (group.to_json() for group in @groups)}


module.exports = Server