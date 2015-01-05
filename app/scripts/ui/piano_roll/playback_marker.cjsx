React = require 'react/addons'


module.exports = React.createClass

  mixins: [
    React.addons.PureRenderMixin
  ]

  propTypes:
    position: React.PropTypes.number.isRequired
    loopSize: React.PropTypes.number.isRequired
    width: React.PropTypes.number.isRequired
    height: React.PropTypes.number.isRequired
    xScale: React.PropTypes.number.isRequired
    xScroll: React.PropTypes.number.isRequired
    quantization: React.PropTypes.number.isRequired

  render: ->
    width = @props.width
    height = @props.height
    position = @props.position % @props.loopSize
    cols = @props.xScale * @props.quantization
    squareWidth = width / cols

    if position >= @props.xScroll and position <= @props.xScroll + @props.xScale
      x = Math.floor(position * @props.quantization) * squareWidth
      unless x <= 0
        el = <line key='pb' x1={x} y1={0} x2={x} y2={height}/>

    <g className="playback">{el}</g>
