class @DrumkitSynthesizer extends Model

  minFreq = 60
  maxFreq = 3000
  freqScale = maxFreq - minFreq

  defaults:
    level: 0.5
    pan: 0.5
    drum0:
      name: 'Kick'
      level: 1
      hp: 0
      decay: 0.3
      noise: 0.001
      pitch: 0
      bend: 0.2
      fm: 1
      fmDecay: 0.15
      fmFreq: 0.48
    drum1:
      name: 'Snare'
      level: 0.7
      hp: 0.22
      decay: 0.1
      noise: 0.8
      pitch: 0.1
      bend: 0
      fm: 0
      fmDecay: 0
      fmFreq: 0
    drum2:
      name: 'HH1'
      level: 0.05
      hp: 1
      decay: 0.07
      noise: 0.8
      pitch: 0.4
      bend: 0
      fm: 1
      fmDecay: 0.4
      fmFreq: 0
    drum3:
      name: 'HH2'
      level: 0.2
      hp: 0.6
      decay: 0.22
      noise: 1
      pitch: 0.5
      bend: 0
      fm: 0
      fmDecay: 0
      fmFreq: 0
    drum4:
      name: 'Perc'
      level: 0.5
      hp: 0.25
      decay: 0.2
      noise: 0.05
      pitch: 0.1
      bend: 0
      fm: 0
      fmDecay: 0
      fmFreq: 0

  mapping: [
    'drum0'
    'drum1'
    'drum2'
    'drum3'
    'drum4'
  ]

  constructor: ->
    super
    @notes = {}
    @filters = (highpassFilter() for drum in @mapping)

  reset: ->
    @notes = {}

  out: (time) ->
    return 0 if @state.level == 0

    # sum all active notes
    @state.level * @mapping.reduce((memo, drumName, index) =>
      return memo unless @notes[index]?
      drum = @state[drumName]
      elapsed = time - @notes[index]
      return memo if elapsed > drum.decay

      level = drum.level * simpleEnvelope drum.decay, elapsed
      freq = minFreq + drum.pitch * freqScale

      if drum.fm > 0
        signal = oscillators.sine elapsed, freq * Math.pow(2, 1 + (drum.fmFreq - 0.5)*2) / 2
        freq += drum.fm * signal * simpleEnvelope(drum.fmDecay + 0.01, elapsed) 

      sample = (
        (1 - drum.noise) * oscillators.sine(elapsed, freq) +
        drum.noise * oscillators.noise()
      )

      if drum.hp > 0
        sample = @filters[index] sample, drum.hp

      memo + level * sample
    , 0)

  tick: (time, i, beat, bps, notesOn) =>
    # add new notes
    notesOn.forEach (note) =>
      @notes[note.key] = time if @mapping[note.key]?