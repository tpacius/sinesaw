React = require 'react/addons'

keyPattern = [true, false, true, false, true, true, false, true, false, true, false, true]


module.exports = React.createClass

  mixins: [React.addons.PureRenderMixin]

  propTypes:
    width: React.PropTypes.number.isRequired
    height: React.PropTypes.number.isRequired
    yScale: React.PropTypes.number.isRequired
    xScale: React.PropTypes.number.isRequired
    yScroll: React.PropTypes.number.isRequired
    xScroll: React.PropTypes.number.isRequired
    quantization: React.PropTypes.number.isRequired

  render: ->
    width = @props.width
    height = @props.height
    squareHeight = height / @props.yScale
    quantization = @props.quantization
    cols = @props.xScale * quantization
    squareWidth = width / cols

    els = []

    minRow = @props.yScroll
    maxRow = minRow + @props.yScale
    rows = [minRow...maxRow]
    
    minCol = @props.xScroll * quantization
    maxCol = minCol + @props.xScale * quantization
    cols = [minCol...maxCol]

    # row shading
    for row, i in rows
      unless keyPattern[row % 12]
        y = height - (i + 1) * squareHeight
        els.push <rect key={'s'+i} x={0} y={y} width={width} height={squareHeight} className='shade'/>

    # horizontal lines
    for row, i in rows
      unless (128 - row) % 12 == 0
        y = i * squareHeight
        els.push <line key={'h'+i} x1={0} y1={y} x2={width} y2={y}/>

    # vertical lines
    for col, i in cols
      unless col % quantization == 0
        x = i * squareWidth
        els.push <line key={'v'+i} x1={x} y1={0} x2={x} y2={height}/>

    # strong horizontal lines
    for row, i in rows
      if (128 - row) % 12 == 0
        y = i * squareHeight
        els.push <line key={'hs'+i} x1={0} y1={y} x2={width} y2={y} className='strong'/>

    # strong vertical lines
    for col, i in cols
      if col % quantization == 0
        x = i * squareWidth
        els.push <line key={'vs'+i} x1={x} y1={0} x2={x} y2={height} className='strong'/>

    <g>{els}</g>
