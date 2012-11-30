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

  playFromKeystroke: (keystroke) ->
    keyboard_key = P.Keyboard.key_mappings[keystroke]
    @playKey($("##{keyboard_key}")) if keyboard_key != undefined

  playKey: (key) ->
    name = key.attr('id')
    sound = $("#sound_#{name}")[0]
    sound.currentTime = 0
    sound.play()
    key.addClass('active')
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
  constructor: (@keyboard) ->
    @at = 0
    #@notes = [['c', 'd'], ['c'], ['d']]
    @notes = ['j', 'j', 'j', 600, 'j', 'j', 'j', 600, 'j', 'l', 'g', 'h', 'j', 600, 'k', 'k', 'k', 'k', 'k', 'k', 600, 'j', 'j', 'j', 'l', 'l', 'k', 'h', 'g']

  play: ->
    @playNextNotes()

  playNextNotes: ->
    keys_to_play = @notes[@at]
    if keys_to_play?
      @at += 1
      # Pause
      if typeof keys_to_play == 'number'
        @playIn(keys_to_play)
      else
        # set up as array
        keys_to_play = [keys_to_play] if typeof keys_to_play == 'string'
        for key in keys_to_play
          @keyboard.playFromKeystroke(key)
        @playIn(400)
    else
      @at = 0
      console.log 'done!'

  playIn: (milliseconds_delay) ->
    setTimeout( =>
      @playNextNotes()
    ,milliseconds_delay)
