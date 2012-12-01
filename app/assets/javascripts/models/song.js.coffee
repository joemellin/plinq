class P.Collections.Songs extends Backbone.Collection
  model: P.Models.Song
  url: '/songs'

class P.Models.Song extends Backbone.Model
  defaults:
    keyboard: null
    at: 0
    tracking: false
    recording: false
    paused: false
    speed: 1
    last_note_at: null
    notes: []
    
   # Sets the right millisecond interval to match tempo
   # whole note is 1, 1/2 note is 2, 1/4 is 4, 1/8 note is 8 etc
  lengthForNote: (interval) ->
    return interval if @get('speed') == 1
    interval / @get('speed')

  startRecording: ->
    @initializeRecording()

  stopRecording: ->
    @set('recording', false)
    @get('keyboard').toggleRecordButton(true, true)

  startTracking: ->
    @set('tracking', true)

  isTracking: ->
    @get('tracking') == true

  moveForwardIfCorrectNote: (note) ->
    if @get('notes')[@get('at')]?
      @set('at', @get('at') + 1) if note == @get('notes')[@get('at')][0]
    @set('at', 0) if @get('at') != 0 && !@get('notes')[@get('at')]?

  addNote: (note) ->
    notes = @get('notes')
    if notes.length > 0 && @get('last_note_at') != null
      diff = new Date() - @get('last_note_at')
      # Modify prev record to show diff to next note
      notes = @get('notes')
      notes[notes.length - 1].push(diff)
    @set('last_note_at', new Date())
    # And add note with zero delay
    notes.push([note])
    @set('notes', notes)
    
  deleteRecording: ->
    @initializeRecording()

  initializeRecording: ->
    @set(last_note_at: null, notes: [], recording: true)

  isRecording: ->
    @get('recording') == true

  play: ->
    @stopRecording()
    @set('at', 0)
    @playNextNotes()

  pause: ->
    if @get('paused') == true
      @set('paused', false)
      # Reset to beginning of song
      @set('at', 0) unless @get('notes')[@get('at')]?
      @playNextNotes()
    else
      @set('paused', true)

  done: ->
    @set('at', 0)
    @get('keyboard').togglePlayButton(true)
    @get('keyboard').updateHud()

  playNextNotes: ->
    key_and_delay = @get('notes')[@get('at')]
    if key_and_delay?
      @set('at', @get('at') + 1)
      @get('keyboard').playKey($("##{key_and_delay[0]}"))
      if key_and_delay[1]?
        @playIn(@lengthForNote(key_and_delay[1])) 
      else
        @done()
    else
      @done()

  playIn: (milliseconds_delay) ->
    if milliseconds_delay < 5
      @playNextNotes()
    else
      setTimeout( =>
        @playNextNotes()
      ,milliseconds_delay)

  nextNotes: ->
    @get('notes')[@get('at')..]