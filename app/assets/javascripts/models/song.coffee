Model = require './model'
webaudio = require '../dsp/webaudio'

module.exports = class Song extends Model

  clockRatio = 230

  defaults:
    bpm: 120
    playing: false
    recording: false
    position: 0

  clip = (sample) ->
    Math.min(2, sample + 1) - 1

  constructor: ->
    super
    @tracks = []
    @ctx = new webkitAudioContext
    @audio = webaudio @ctx, @out

  out: (time, i) =>
    @tick time, i if i % clockRatio is 0

    clip @tracks.reduce((sample, t) ->
      sample + t.out time, i
    , 0)

  tick: (time, i) ->
    bps = @state.bpm / 60
    beat = time * bps

    # update ui state on 1/4th notes
    b = Math.floor(beat * 4) / 4
    @set position: b if b > @state.position 

    track.tick time, i, beat, bps for track in @tracks 

  play: =>
    @set playing: true
    @audio.play()

  pause: =>
    @set playing: false
    @audio.stop()

  record: =>
    @set recording: !@state.recording

  stop: =>
    @audio.stop()
    @audio.reset()
    track.reset() for track in @tracks
    @set playing: false, recording: false, position: 0
