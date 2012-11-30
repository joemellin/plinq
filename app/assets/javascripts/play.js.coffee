# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

window.P = {}
window.keyboard = null

$ ->
  window.keyboard = new P.Keyboard '#keyboard'

class P.Keyboard
  @keys: ['c', 'd', 'e', 'f', 'g', 'a', 'b', 'ct', 'dt', 'et', 'cs', 'ds', 'fs', 'gs', 'bb', 'cst', 'dst', 'blank']
  @key_mappings: {a: 'c', s: 'd', d: 'e', f: 'f', g: 'g', h: 'a', j: 'b', k: 'ct', l: 'dt', 'º': 'et', w: 'cs', e: 'ds', t: 'fs', y: 'gs', u: 'bb', o: 'cst', p: 'dst'}

  constructor: (@div_name) ->
    kb = @
    @writeAudioFiles()
    @song = new P.Song()
    @song.keyboard = @

    $("#{@div_name} #keys div").click ->
      kb.playKey($(this))

    $(document).keyup( ->
      kb.resetKeys()
    )
    $(document).keydown( (e) ->
      unicode = e.keyCode
      unicode = unicode|0x20
      key = String.fromCharCode(unicode)
      kb.playFromKeystroke(key)
    )

    $('.start_recording').click ->
      kb.toggleRecordButton($(this), kb)

    $('.play_recording').click ->
      kb.togglePlayButton($(this), kb)

  toggleRecordButton: (btn, kb) ->
    if $(btn).hasClass('btn-success')
      kb.song.stopRecording()
      $(btn).removeClass('btn-success').addClass('btn-danger')
    else
      kb.song.startRecording()
      $(btn).removeClass('btn-danger').addClass('btn-success')

  togglePlayButton: (btn, kb) ->
    if $(btn).find('i').hasClass('icon-pause')
      kb.song.pause()
      $(btn).find('i').removeClass('icon-pause').addClass('icon-play')
    else
      kb.song.play()
      $(btn).find('i').removeClass('icon-play').addClass('icon-pause')

  playFromKeystroke: (keystroke, dont_record = false) ->
    keyboard_key = P.Keyboard.key_mappings[keystroke]
    @playKey($("##{keyboard_key}"), dont_record) if keyboard_key != undefined

  playKey: (key, dont_record = false) ->
    name = key.attr('id')
    sound = $("#sound_#{name}")[0]
    sound.currentTime = 0
    sound.play()
    key.addClass('active')
    @song.addNote(name) if dont_record != true && @song.isRecording()
    setTimeout( =>
      @resetKeys()
    , 130)
    $("#current_key").text(name.toUpperCase())

  writeAudioFiles: ->
    for key in P.Keyboard.keys
      $("#{@div_name} #audio_files").append("<audio preload='auto' id='sound_#{key}' src='/audio/#{key}.wav'></audio>")

  resetKeys: ->
    $("#{@div_name} #keys div").removeClass('active')


class P.Song
  constructor: (@keyboard, @tempo = 120) ->
    @at = 0
    @setTempo(@tempo)
    @notes = []
    #@notes = ['j2', 'j2', 'j2', 1, 'j2', 'j2', 'j2', 1, 'j2', 'l4', 'g1', 'h2', 'j2', 1, 'k2', 'k2', 'k2', 'k2', 'k2', 'k2', 1, 'j2', 'j2', 'j2', 'l2', 'l2', 'k2', 'h2', 'g2']

    # Sets the right millisecond interval to match tempo
  setTempo: (tempo) ->
    @tempo = tempo
    @interval = 60000 / tempo

   # whole note is 1, 1/2 note is 2, 1/4 is 4, 1/8 note is 8 etc
  lengthForNote: (note) ->
    @interval / note

  startRecording: ->
    @initializeRecording()

  stopRecording: ->
    @recording = false

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

  stop: ->
    # to do

  playNextNotes: ->
    key_and_delay = @notes[@at]
    if key_and_delay?
      console.log key_and_delay
      @at += 1
      @keyboard.playKey($("##{key_and_delay[0]}"))
      @playIn(key_and_delay[1]) if key_and_delay[1]?
    else
      @at = 0
      console.log 'done!'
      #@keyboard.togglePlayButton($('.play_recording'), @keyboard)

  playIn: (milliseconds_delay) ->
    if milliseconds_delay > 5
      @playNextNotes()
    else
      setTimeout( =>
        @playNextNotes()
      ,milliseconds_delay)
