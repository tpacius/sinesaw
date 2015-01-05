React = require 'react/addons'

keyPattern = [true, false, true, false, true, true, false, true, false, true, false, true]


module.exports = React.createClass

  mixins: [
    React.addons.PureRenderMixin
  ]

  propTypes:
    height: React.PropTypes.number.isRequired
    yScroll: React.PropTypes.number.isRequired
    yScale: React.PropTypes.number.isRequired
    keyWidth: React.PropTypes.number.isRequired

  render: ->
    height = @props.height
    keyHeight = height / @props.yScale
    keyWidth = @props.keyWidth

    els = []

    minRow = @props.yScroll
    maxRow = minRow + @props.yScale
    rows = [minRow...maxRow]

    # keys
    for row, i in rows
      unless keyPattern[row % 12]
        y = height - (i + 1) * keyHeight
        text = null
        els.push <rect key={'k' + i} x={0} y={y} width={keyWidth} height={keyHeight}/>

    # # lines
    # for row, i in rows
    #   y = i * keyHeight
    #   els.push <line key={'l' + i} x1={0} y1={y} x2={keyWidth} y2={y}/>

    # text
    for row, i in rows
      if row % 12 == 0
        y = height - (i + 0.5) * keyHeight
        text = "C #{Math.floor(row / 12) - 2}"
        els.push <text key={'t' + i} x={keyWidth - 4} y={y}>{text}</text>

    <div className='keys'>
      <svg width={keyWidth} height={height} onClick={@props.onClick}>
        {els}
      </svg>
    </div>
