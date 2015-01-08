deepFreeze = require './deep_freeze'
deepMerge = require './deep_merge'
UndoHistory = require './undo_history'


# return true if an object has no properites, false otherwise
isEmpty = (o) ->
  for k, v of o
    return false if o.hasOwnProperty k
  true


class Cache

  constructor: ->
    @root = children: {}

  get: (path) ->
    target = @root
    for key in path
      target = target.children[key]
      return undefined unless target?
    target.cursor

  store: (cursor) ->
    target = @root
    for key in cursor.path
      target.children[key] ||= children: {}
      target = target.children[key]
    target.cursor = cursor

  clearPath: (path) ->
    target = @root
    nodes = []

    # clear cached cursors along path
    for key, i in path
      break unless target.children[key]?
      target = target.children[key]
      nodes.push target
      delete target.cursor

    # prune empty nodes along path starting at leaves
    # for i in [nodes.length - 1 ... 0]
    #   node = nodes[i]
    #   if isEmpty node.children
    #     delete nodes[i - 1].children[path[i]]
    #   else
    #     break

    @root

  # recursively clear changes made by merge

  clearObject = (node, changes) ->
    for k of changes
      if (child = node.children[k])?
        delete child.cursor
        clearObject child, changes[k]
    node

  clearObject: (path, obj) ->
    target = @root
    for key in path
      target = target.children[key]
      return unless target?

    clearObject target, obj



module.exports =

  create: (inputData, onChange) ->
    cache = new Cache
    history = new UndoHistory
    data = deepFreeze inputData
    batched = false

    # declare cursor class w/ access to mutable reference to data in closure
    class Cursor

      constructor: (@path = []) ->

      cursor: (path = []) ->
        fullPath = @path.concat path

        return cached if (cached = cache.get fullPath)?

        cursor = new Cursor fullPath
        cache.store cursor
        cursor

      get: (path = []) ->
        target = data
        for key in @path.concat path
          target = target[key]
          return undefined unless target?
        target

      modifyAt: (path, modifier, historic) ->
        fullPath = @path.concat path

        newData = target = {}
        target[k] = v for k, v of data

        for key in fullPath.slice 0, -1
          updated = if Array.isArray target[key] then [] else {}
          updated[k] = v for k, v of target[key]
          target[key] = updated
          Object.freeze target
          target = target[key]

        modifier target, fullPath.slice -1
        Object.freeze target

        cache.clearPath fullPath
        update newData, historic

      set: (path, value, historic = false) ->
        if arguments.length is 1
          value = path
          path = []

        if @path.length > 0 or path.length > 0
          @modifyAt path, (target, key) ->
            target[key] = deepFreeze value
          , historic
        else
          update value

      delete: (path) ->
        if @path.length > 0 or path.length > 0
          @modifyAt path, (target, key) ->
            delete target[key]
          , historic
        else
          update undefined

      merge: (newData, historic = false) ->
        cache.clearObject @path, newData
        @set [], deepMerge(@get(), deepFreeze newData), historic

      bind: (path, pre, historic = false) ->
        (v) => @set path, (if pre then pre v else v), historic

      has: (path) ->
        @get(path)?

      batched: (cb, historic = false) ->
        batched = true
        cb()
        batched = false
        update data, historic


    update = (newData, historic) ->
      data = newData

      unless batched
        cursor = new Cursor()
        history.update cursor if historic
        onChange cursor, history


    # perform callback one time to start
    onChange new Cursor(), history

