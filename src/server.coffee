http      = require 'http'
fs        = require 'fs'

SocketIO  = require 'socket.io'
request   = require 'request'

Channel   = require './channel'
Light     = require './light'
Group     = require './group'
Preset    = require './preset'
Base      = require './base'

class Server extends Base
  constructor: (@config, @save_name) ->
    super
    @dirty = false
    @sock = http.createServer()
    @server = new SocketIO(@sock)
    @sock.listen @config.general.port, () =>
      console.log "Listening on #{@config.general.port}"

    @groups = []
    for group in @config.groups
      gro = new Group group
      @groups.push gro
      gro.on "changed", () =>
        @dirty = true

    @presets = []
    fs.readFile @save_name, {encoding: 'utf8'}, (err, data) =>
      if not err
        for preset_data in JSON.parse(data).presets
          @presets.push new Preset(preset_data.name, preset_data.data)

    @interval = setInterval( () =>
      @check_dirty()
    ,1000 / @config.general.update_hz)

    @server.on "connection", (socket) =>
      process.stdout.write "C"
      @send_ws(socket)

      socket.on "update", (data) =>
        process.stdout.write "I"
        socket.broadcast.emit "update", data
        for group in data.groups
          for ingroup in @groups
            if group.name == ingroup.name
              ingroup.update group.lights if group.lights?

      socket.on "save", (data) =>
        process.stdout.write "S"
        for preset in @presets
          if preset.name == data.name
            preset.save_state @
            return
        preset = new Preset(data.name)
        preset.save_state @
        @dirty = true
        @presets.push preset
        fs.writeFile @save_name, JSON.stringify({presets: @presets})
        @push_all_ws()

      socket.on "load", (data) =>
        process.stdout.write "L"
        for preset in @presets
          if preset.name == data.name
            preset.load_state @
            @push_all_ws()
            return

  check_dirty: () ->
    if @dirty
      # @send_ws()
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

  push_all_ws: () ->
    for socket in @server.sockets.sockets
      @send_ws socket

  send_ws: (socket) ->
    socket.emit "full_update", {
      groups: (group.to_json() for group in @groups)
      presets: (preset.to_json() for preset in @presets)
    }


module.exports = Server