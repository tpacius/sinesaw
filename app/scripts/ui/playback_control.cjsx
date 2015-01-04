# this renders the top bar of the application with playback and temp controls.
# PlaybackController accepts one property - a song cursor

React = require 'react'
ScaleHandle = require './scale_handle'
Keyboard = require 'keyboardjs'

module.exports = React.createClass

  componentDidMount: ->
    @keyBindings = [
      Keyboard.on 'space', @onSpaceKey
    ]

  propTypes:
    song: React.PropTypes.object.isRequired

  componentWillUnmount: ->
    binding.clear() for binding in @keyBindings

  onSpaceKey: (e) ->
    e.preventDefault()
    @props.song.set 'playing', not @props.song.get 'playing'

  render: ->
    song = @props.song
    playing = song.get 'playing'

    <div className="ui playback-control">
      <div className="group playback">
        <div
          className={"icon icon-play#{if playing then ' active' else ''}"}
          onClick={song.bind 'playing', -> not song.get 'playing'}
        />
        <div className="icon icon-record"/>
        <div className="icon icon-stop" onClick={song.bind 'playing', -> false}/>
      </div>
      <div className="group tempo">
        <select
          value={song.get 'bpm'}
          onChange={song.bind 'bpm', (e) -> parseInt e.target.value}
        >
          {
            for i in [200..20]
              <option key={i} value={i}>{i} bpm</option>
          }
        </select>
      </div>
      <div className="logo">sinesaw</div>
      <div className="group menu">
        <div className="icon icon-air"/>
      </div>
    </div>
