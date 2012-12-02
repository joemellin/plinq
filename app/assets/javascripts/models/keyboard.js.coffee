class P.Models.Keyboard extends Backbone.Model
  defaults:
    keys: ['c', 'd', 'e', 'f', 'g', 'a', 'b', 'ct', 'dt', 'et', 'cs', 'ds', 'fs', 'gs', 'bb', 'cst', 'dst', 'blank']
    keyboard_mappings: {a: 'c', s: 'd', d: 'e', f: 'f', g: 'g', h: 'a', j: 'b', k: 'ct', l: 'dt', 'º': 'et', w: 'cs', e: 'ds', t: 'fs', y: 'gs', u: 'bb', o: 'cst', p: 'dst'}
    reverse_keyboard_mappings:  {c: 'a', d: 's', e: 'd', f: 'f', g: 'g', a: 'h', b: 'j', ct: 'k', dt: 'l', et: ';', cs: 'w', ds: 'e', fs: 't', gs: 'y', bb: 'u', cst: 'o', dst: 'p'}
    control_keys: {1: 'toggleRecordButton', 2: 'togglePlayButton', 32: 'togglePlayButton', 3: 'startTracking', 4: 'saveSong'}
    song: null
    div_name: null

  constructor: (attr) ->
    super attr
    @song = attr.song
    console.log @song

  setup: ->
    @writeAudioFiles()
    kb = @

    $("#{@get('div_name')} #keys div").click ->
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
      kb.get('song').startTracking()

    $('.save_song').click ->
      kb.saveSong()

  saveSong: ->
    @song.save().success ->
      alert('Your song has been saved!')


  reverseKeyboardMappingFor: (key) ->
    for keyboard_key in @get('keyboard_mappings')
      return keyboard_key if the_key == key
    return null

  toggleRecordButton: (dont_control_song = false, force_stop = false) ->
    btn = $('.start_recording')
    if btn.hasClass('btn-success') || force_stop
      @stopRecording(dont_control_song)
    else
      @startRecording() unless dont_control_song
      btn.removeClass('btn-danger').addClass('btn-success')
      btn.find('i').addClass('icon-stop').removeClass('icon-volume-up')

  togglePlayButton: (dont_control_song = false) ->
    btn = $('.play_recording')
    if btn.find('i').hasClass('icon-pause')
      P.keyboard.song.pause() unless dont_control_song
      btn.find('i').removeClass('icon-pause').addClass('icon-play')
    else
      P.keyboard.song.play() unless dont_control_song
      btn.find('i').removeClass('icon-play').addClass('icon-pause')

  startRecording: ->
    P.keyboard.song = new P.Models.Song() unless P.keyboard.song.isNew()
    P.keyboard.song.startRecording()

  stopRecording: (dont_control_song = false) ->
    btn = $('.start_recording')
    P.keyboard.song.stopRecording() unless dont_control_song
    btn.removeClass('btn-success').addClass('btn-danger')
    btn.find('i').removeClass('icon-stop').addClass('icon-volume-up')

  playFromKeystroke: (keystroke, key_code) ->
    keyboard_key = @get('keyboard_mappings')[keystroke]
    if keyboard_key != undefined
      @playKey($("##{keyboard_key}"))
    else
      control = @get('control_keys')[keystroke]
      control = @get('control_keys')[key_code] unless control?
      @[control]() if control?

  playKey: (key, dont_record = false) ->
    name = key.attr('id')
    sound = $("#sound_#{name}")[0]
    sound.currentTime = 0
    sound.play()
    key.addClass('active')
    @song.keyPlayed(name)
    setTimeout( =>
      @resetKeys()
    , 130)

  startTracking: ->
    @stopRecording()
    @song.startTracking()
    $('.learn i').addClass('btn-success')

  writeAudioFiles: ->
    for key in @get('keys')
      $("#{@get('div_name')} #audio_files").append("<audio preload='auto' id='sound_#{key}' src='/audio/#{key}.wav'></audio>")

  resetKeys: ->
    $("#{@get('div_name')} #keys div").removeClass('active')