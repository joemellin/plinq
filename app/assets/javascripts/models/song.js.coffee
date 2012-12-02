class P.Models.Song extends Backbone.Model
  defaults:
    at: 0
    tracking: true # by default set to tracking
    recording: false
    paused: false
    speed: 1
    last_note_at: null
    times_played: 0
    recordingSong: null
    notes: []

  urlRoot: '/songs'

  defaultShareMessage: ->
    "Boom! I just learned to play #{@get('title')} on Plinq :)"

   # Sets the right millisecond interval to match tempo
   # whole note is 1, 1/2 note is 2, 1/4 is 4, 1/8 note is 8 etc
  lengthForNote: (interval) ->
    return interval if @get('speed') == 1
    interval / @get('speed')

  startRecording: ->
    @initializeRecording()

  stopRecording: ->
    @set('recording', false)
    P.keyboard.toggleRecordButton(true, true)

  startTracking: ->
    @set('tracking', true)

  isTracking: ->
    @get('tracking') == true

  moveForwardIfCorrectNote: (note) ->
    if @get('notes')[@get('at')]?
      @set('at', @get('at') + 1) if note == @get('notes')[@get('at')][0]
    if @get('at') != 0 && !@get('notes')[@get('at')]?
      @done('play') 

  keyPlayed: (name) ->
    @addNote(name) if @isRecording()
    if @isTracking()
      @recordingSong = new P.Models.Song(title: @get('title'), artist: @get('artist')) unless @recordingSong
      @moveForwardIfCorrectNote(name)
      @recordingSong.addNote(name)

  pctCompletePlayingSong: ->
    return 0 unless @recordingSong?
    recorded_notes = @recordingSong.get('notes').length
    return 0 if recorded_notes == 0
    two_bars = @get('notes').length * 2
    Math.round((recorded_notes / two_bars) * 100)

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

  done: (type = 'listen') ->
    @set('at', 0)
    @set('times_played', @get('times_played') + 1)
    if @recordingSong?
      two_bars = @get('notes').length * 2
      recorded_notes = @recordingSong.get('notes')
      # just keep last two bars played in recording song
      if recorded_notes.length > two_bars
        end_at = recorded_notes.length - 1
        last_two_bars_start = end_at - two_bars
        @recordingSong.set('notes', recorded_notes[last_two_bars_start..end_at]) if recorded_notes.length > last_two_bars_start
    if type == 'listen'
      @recordListened()
    else if type == 'play'
      @recordPlayed()

  playNextNotes: ->
    key_and_delay = @get('notes')[@get('at')]
    if key_and_delay?
      @set('at', @get('at') + 1)
      P.keyboard.playKey($("##{key_and_delay[0]}"))
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
    notes = @get('notes')[@get('at')..]
    tmp = []
    for note in notes
      tmp.push P.keyboard.get('reverse_keyboard_mappings')[note[0]]
    tmp

  save: ->
    @set('title', $('#song_title').val()) if $('#song_title').length > 0
    @set('artist', $('#song_artist').val()) if $('#song_artist').length > 0
    @set('original_song_id', window.original_song_id) if window.original_song_id?
    super

  shareRecording: ->
    if @recordingSong?
      @recordingSong.save().success =>
        $('#share_song_form #song_id').val(@recordingSong.get('id'))
        $('#share_song_form').submit()

  recordPlayed: ->
    $.post(@url() + '/played')

  recordListened: ->
    $.post(@url() + '/listened')



class P.Collections.Songs extends Backbone.Collection
  model: P.Models.Song
  url: '/songs'