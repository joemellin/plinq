# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

window.P = {}
window.keyboard = null

$ ->
  window.keyboard = new P.Keyboard '#keyboard'
  window.keyboard.updateHud()

class P.Keyboard
  @keys: ['c', 'd', 'e', 'f', 'g', 'a', 'b', 'ct', 'dt', 'et', 'cs', 'ds', 'fs', 'gs', 'bb', 'cst', 'dst', 'blank']
  @keyboard_mappings: {a: 'c', s: 'd', d: 'e', f: 'f', g: 'g', h: 'a', j: 'b', k: 'ct', l: 'dt', 'º': 'et', w: 'cs', e: 'ds', t: 'fs', y: 'gs', u: 'bb', o: 'cst', p: 'dst'}
  @reverse_keyboard_mappings:  {c: 'a', d: 's', e: 'd', f: 'f', g: 'g', a: 'h', b: 'j', ct: 'k', dt: 'l', et: ';', cs: 'w', ds: 'e', fs: 't', gs: 'y', bb: 'u', cst: 'o', dst: 'p'}
  @control_keys: {1: 'toggleRecordButton', 2: 'togglePlayButton', 32: 'togglePlayButton', 3: 'startTracking'}

  constructor: (@div_name) ->
    @writeAudioFiles()
    @song = new P.Song(@)
    @
    kb = @

    $("#{@div_name} #keys div").click ->
      kb.playKey($(this))

    $(document).keyup( ->
      kb.resetKeys()
    )
    $(document).keydown( (e) ->
      unicode = e.keyCode
      unicode = unicode|0x20
      key = String.fromCharCode(unicode)
      kb.playFromKeystroke(key, e.keyCode)
    )

    $('.start_recording').click ->
      kb.toggleRecordButton()

    $('.play_recording').click ->
      kb.togglePlayButton()

    $('.learn').click ->
      kb.song.startTracking()

  reverseKeyboardMappingFor: (key) ->
    for keyboard_key in P.Keyboard.keyboard_mappings
      console.log "#{keyboard_key}"
      return keyboard_key if the_key == key
    return null

  toggleRecordButton: (dont_control_song = false, force_stop = false) ->
    btn = $('.start_recording')
    if btn.hasClass('btn-success') || force_stop
      @stopRecording(dont_control_song)
    else
      keyboard.song.startRecording() unless dont_control_song
      btn.removeClass('btn-danger').addClass('btn-success')
      btn.find('i').addClass('icon-stop').removeClass('icon-volume-up')

  togglePlayButton: (dont_control_song = false) ->
    btn = $('.play_recording')
    if btn.find('i').hasClass('icon-pause')
      keyboard.song.pause() unless dont_control_song
      btn.find('i').removeClass('icon-pause').addClass('icon-play')
    else
      keyboard.song.play() unless dont_control_song
      btn.find('i').removeClass('icon-play').addClass('icon-pause')

  stopRecording: (dont_control_song = false) ->
    btn = $('.start_recording')
    keyboard.song.stopRecording() unless dont_control_song
    btn.removeClass('btn-success').addClass('btn-danger')
    btn.find('i').removeClass('icon-stop').addClass('icon-volume-up')

  playFromKeystroke: (keystroke, key_code) ->
    keyboard_key = P.Keyboard.keyboard_mappings[keystroke]
    if keyboard_key != undefined
      @playKey($("##{keyboard_key}"))
    else
      control = P.Keyboard.control_keys[keystroke]
      control = P.Keyboard.control_keys[key_code] unless control?
      @[control]() if control?

  playKey: (key, dont_record = false) ->
    name = key.attr('id')
    sound = $("#sound_#{name}")[0]
    sound.currentTime = 0
    sound.play()
    key.addClass('active')
    @song.addNote(name) if dont_record != true && @song.isRecording()
    @song.moveForwardIfCorrectNote(name) if @song.isTracking()
    setTimeout( =>
      @resetKeys()
    , 130)
    @updateHud()

  startTracking: ->
    @stopRecording()
    @song.startTracking()
    $('.learn i').addClass('btn-success')

  updateHud: ->
    $('#key_groups').html('')
    for note in @song.nextNotes()
      keyboard_key = P.Keyboard.reverse_keyboard_mappings[note[0]]
      $('#key_groups').append('<div class="left key_group">' + keyboard_key.toUpperCase() + '</div>') if keyboard_key?

  writeAudioFiles: ->
    for key in P.Keyboard.keys
      $("#{@div_name} #audio_files").append("<audio preload='auto' id='sound_#{key}' src='/audio/#{key}.wav'></audio>")

  resetKeys: ->
    $("#{@div_name} #keys div").removeClass('active')


class P.Song
  constructor: (@keyboard, @speed = 1) ->
    @at = 0
    @tracking = @recording = false
    @speed = 1
    @notes = []
    
   # Sets the right millisecond interval to match tempo
   # whole note is 1, 1/2 note is 2, 1/4 is 4, 1/8 note is 8 etc
  lengthForNote: (interval) ->
    return interval if @speed == 1
    interval / @speed

  startRecording: ->
    @initializeRecording()

  stopRecording: ->
    @recording = false
    @keyboard.toggleRecordButton(true, true)

  startTracking: ->
    @tracking = true

  isTracking: ->
    @tracking == true

  moveForwardIfCorrectNote: (note) ->
    if @notes[@at]?
      @at += 1 if note == @notes[@at][0]
    @at = 0 if @at != 0 && !@notes[@at]?

  addNote: (note) ->
    if @notes.length > 0 && @last_note_at != null
      diff = new Date() - @last_note_at
      # Modify prev record to show diff to next note
      @notes[@notes.length - 1].push(diff)
    @last_note_at = new Date()    
    # And add note with zero delay
    @notes.push([note])
    
  deleteRecording: ->
    @initializeRecording()

  initializeRecording: ->
    @last_note_at = null
    @notes = []
    @recording = true

  isRecording: ->
    @started_recording_at != null && @recording

  play: ->
    @stopRecording()
    @at = 0
    @playNextNotes()

  pause: ->
    if @pause == true
      @pause = false
      # Reset to beginning of song
      @at = 0 unless @notes[@at]?
      @playNextNotes()
    else
      @pause = true

  done: ->
    console.log 'done!'
    @at = 0
    @keyboard.togglePlayButton(true)
    @keyboard.updateHud()

  playNextNotes: ->
    key_and_delay = @notes[@at]
    if key_and_delay?
      @at += 1
      @keyboard.playKey($("##{key_and_delay[0]}"))
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
    @notes[@at..]
