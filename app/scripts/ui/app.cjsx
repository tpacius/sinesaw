# this is the top level react component - it handles window layout, track
# selection, and modal state.  It expects only one prop, 'data', a root cursor
# to a song object.

React = require 'react'
PlaybackControl = require './playback_control'
TrackSelection = require './track_selection'
PianoRoll = require './piano_roll'
BasicSamplerControl = require './basic_sampler_control'
AnalogSynthesizerControl = require './analog_synthesizer_control'
DrumSynthesizerControl = require './drum_synthesizer_control'
DrumSamplerControl = require './drum_sampler_control'
LoopSamplerControl = require './loop_sampler_control'
Modal = require './modal'
KeyboardInteraction = require './mixins/keyboard_interaction'
ReactCSSTransitionGroup = React.addons.CSSTransitionGroup

module.exports = React.createClass

  displayName: 'App'

  propTypes:
    data: React.PropTypes.object.isRequired
    song: React.PropTypes.object.isRequired
    midiState: React.PropTypes.object
    playbackState: React.PropTypes.object

  mixins: [
    KeyboardInteraction
  ]

  getInitialState: ->
    modalContent: null
    modalIndex: 0

  launchModal: (modalContent) ->
    @props.data.set 'playing', false
    @setState {modalContent, modalIndex: @state.modalIndex + 1}

  dismissModal: ->
    @setState modalContent: null

  render: ->
    selectedTrack = @props.data.get 'selectedTrack'
    track = @props.data.cursor ['tracks', selectedTrack]
    position = @props.song.getPosition()
    empty = not track.get()?

    unless empty
      sequence = track.cursor 'sequence'
      instrument = track.cursor 'instrument'

      ControlClass = switch instrument.get '_type'
        when 'BasicSampler' then BasicSamplerControl
        when 'AnalogSynthesizer' then AnalogSynthesizerControl
        when 'DrumSynthesizer' then DrumSynthesizerControl
        when 'DrumSampler' then DrumSamplerControl
        when 'LoopSampler' then LoopSamplerControl
        else null

      if ControlClass?
        instrumentControl =
          <ControlClass
            key={track.get '_id'}
            instrument={instrument}
            app={this}
          />

    <div className="app">
      <div className="row playback">
        <PlaybackControl
          data={@props.data}
          song={@props.song}
          playing={@props.song.playing}
          buffer={@props.song.buffer}
        />
      </div>
      <div className="row main">
        <div className="column sidebar">
          <TrackSelection
            tracks={@props.data.cursor 'tracks'}
            selectedTrack={selectedTrack}
            selectTrack={(v) => @props.data.set 'selectedTrack', parseInt v}
            meterLevels={@props.playbackState?.meterLevels}
          />
        </div>
        <div className="column main">
          <div className="row sequence">
            {
              unless empty
                <PianoRoll
                  data={@props.data}
                  midiNotes={@props.song.midi.notes}
                  sequence={sequence}
                  position={position}
                />
            }
          </div>
          <div className="row instrument">
            {instrumentControl}
          </div>
        </div>
      </div>
      <ReactCSSTransitionGroup transitionName="modal">
        {
          if @state.modalContent?
            <Modal key={@state.modalIndex}>{@state.modalContent}</Modal>
        }
      </ReactCSSTransitionGroup>
    </div>
