module.exports = 

  dragStart: (e) ->
    @props.updateDragging parseInt e.currentTarget.dataset.id
    @props.selectTrack parseInt e.currentTarget.dataset.id
 
    e.dataTransfer.effectAllowed = 'move'
    e.dataTransfer.setData 'text/html', null

  dragEnd: ->
    @props.updateDragging null

  dragOver: (e) ->
    e.preventDefault()
    over = e.currentTarget
    relX = e.clientX - over.getBoundingClientRect().left
    relY = e.clientY - over.getBoundingClientRect().top
    height = over.offsetHeight / 2
    append = relY > height

    from = @props.dragging
    to = Number over.dataset.id
    to += 1 if append
    to -= 1 if from < to

    return if from == to

    items = @props.items.get().slice 0
    items.splice to, 0, items.splice(from, 1)[0]

    @props.items.set [], items

    @props.updateDragging to
    @props.selectTrack to

  isDragging: ->
    @props.dragging == @props.index
