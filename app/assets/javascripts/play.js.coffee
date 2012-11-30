# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

window.P = {}

$ ->
  i = new P.Keyboard '#keyboard'

class P.Keyboard
  @notes: ['c', 'd', 'e', 'f', 'g', 'a', 'b', 'ct', 'dt', 'et', 'cs', 'ds', 'fs', 'gs', 'bb', 'cst', 'dst', 'blank']
  @key_mappings: {a: 'c', s: 'd', d: 'e', f: 'f', g: 'g', h: 'a', j: 'b', k: 'ct', l: 'dt', ';': 'et', w: 'cs', e: 'ds', t: 'fs', y: 'gs', u: 'bb', o: 'cst', p: 'dst'}

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
      keyboard_key = P.Keyboard.key_mappings[key]
      kb.playKey($("##{keyboard_key}")) if keyboard_key != undefined
    )

  playKey: (key) ->
    name = key.attr('id')
    sound = $("#sound_#{name}")[0]
    sound.currentTime = 0
    sound.play()
    key.addClass('active')
    kb = @
    setTimeout( =>
      @resetKeys()
    , 130)

  writeAudioFiles: ->
    for note in P.Keyboard.notes
      $("#{@div_name} #audio_files").append("<audio preload=\"auto\" id=\"sound_#{note}\" src=\"/audio/#{note}.wav\"></audio>\"")

  resetKeys: ->
    $("#{@div_name} #keys div").removeClass('active')