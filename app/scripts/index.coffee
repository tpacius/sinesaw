ImmutableData = require './util/immutable_data'
React = require 'react/addons'
SongBridge = require './models/song_bridge'
Song = require './models/song'
App = require './ui/app'


# development only code
if process.env.NODE_ENV is 'development'

  # setup gulp build status / autoreload
  (require 'build-status').client()

  # set these on window for debugging / react dev tools chrome extension
  window.React = React
  window.App = App
  window.Track = require './models/track'
  window.DrumSampler = require './models/drum_sampler'
  window.BasicSampler = require './models/basic_sampler'
  window.TrackSelection = require './ui/track_selection'
  window.Meter = require './ui/meter'
  window.PianoRoll = require './ui/piano_roll'
  window.GridLines = require './ui/piano_roll/grid_lines'
  window.Keys = require './ui/piano_roll/keys'
  window.Notes = require './ui/piano_roll/notes'
  window.PlaybackMarker = require './ui/piano_roll/playback_marker'
  window.Selection = require './ui/piano_roll/selection'


# setup immutable data, dsp thread, and start app
launch = (songData) ->

  song = new SongBridge
  window.data = null
  history = null
  playbackState = null

  # called when playback state is received from audio processing thread
  song.onFrame (state) -> playbackState = state

  # called every time song data changes
  ImmutableData.create songData, (d, h) ->
    # pass updated data to dsp thread
    song.update d

    # keep references to data cursor and history objects
    window.data = d
    history = h

    # save changes in localstorage
    localStorage.setItem 'song', JSON.stringify d.get()


  # render the app for every animation frame
  frame = ->
    React.render(
      React.createElement(App, {song, data, playbackState, history}),
      document.body
    )
    requestAnimationFrame frame

  frame()


document.addEventListener 'DOMContentLoaded', ->

  data = localStorage.getItem 'song'

  if data?
    launch JSON.parse data
  else
    launch Song.build()

  # require('./extra/default_song') launch

