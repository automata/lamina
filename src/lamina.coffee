
demoSample = null

# Abstracting a Novation Launchpad MIDI controller
class Launchpad
  constructor: (init) ->
    window.navigator.requestMIDIAccess().then(@onMIDISuccess, @onMIDIFailure)
    @init = init

  onMIDISuccess: (access) =>
    midiAccess = access
    @midiInput = midiAccess.inputs()[0]

    
    @midiInput.onmidimessage = @onMIDIMessage
    @midiOutput = midiAccess.outputs()[0]
    console.log("MIDI connected!!")
    @init()
    
  onMIDIFailure: (err) ->
    console.log("MIDI Error: ", err.code)

  onMIDIMessage: (event) =>
    command = event.data[0]
    note = event.data[1]
    velocity = event.data[2]
    console.log command, note, velocity

    x = note & 0x0f
    y = (note & 0xf0) >> 4

  updateCell: (row, column, red, green) =>
    @midiOutput.send([0x90, (row << 4) | column, red | (green << 4)])
  

# Abstracting how to load, play and draw sample files
class Sample
  constructor: (url, onReady) ->
    data = null
    source = null
    @load(url)
    @onReady = onReady

  load: (url) ->
    request = new XMLHttpRequest()
    request.open("GET", url, true)
    request.responseType = "arraybuffer"
    request.onload = () =>
      audioContext.decodeAudioData request.response, (buffer) =>
        @data = buffer
        @onReady()
    request.send()

  play: (time=0, offset=0, duration) ->
    @source = audioContext.createBufferSource()
    @source.buffer = @data
    @source.connect(audioContext.destination)
    @source.start(audioContext.currentTime, offset, duration)

  stop: (time=0) ->
    @source.stop(time)
            
  drawOn: (canvas, head) ->
    width = canvas.width
    height = canvas.height
    data = @data.getChannelData(0)
    step = Math.ceil(data.length / width)
    amp = height
    c = canvas.getContext "2d"
    c.clearRect(0, 0, width, height)
    c.beginPath()
    c.moveTo(0, height/2 + data[0])
    for i in [0..width]
      c.lineTo(i, height/2 + data[step*i] * amp)
    c.closePath()
    c.strokeStyle = "green"
    c.stroke()

    if head
      c.beginPath()
      c.moveTo(head, 0)
      c.lineTo(head, height)
      c.closePath()
      c.strokeStyle = "blue"
      c.stroke()

# Multi-brower requestAnimationFrame
window.requestAnimationFrame =
  window.requestAnimationFrame or
  window.mozRequestAnimationFrame or
  window.webkitRequestAnimationFrame or
  window.msRequestAnimationFrame

# Multi-browser AudioContext
window.AudioContext =
  window.AudioContext or
  window.webkitAudioContext

# Waveform canvas setup
canvas = document.getElementById "c"
canvas.width = window.innerWidth
canvas.height = window.innerHeight
c = canvas.getContext "2d"

# Audio setup
audioContext = new AudioContext()

# Gesture events
hammer = Hammer(canvas).on "drag touch", (event) ->
  step = Math.ceil(demoSample.data.length / canvas.width)
  x = event.gesture.center.clientX
  offsetSeconds = x*step / audioContext.sampleRate
  demoSample.stop()
  console.log offsetSeconds
  demoSample.play(0, offsetSeconds)
  demoSample.drawOn(canvas, x)
  return

window.addEventListener 'load', () ->
  # Main
  demoSample = new Sample "samples/demo.wav", () ->
    @drawOn(canvas)
    @play()
    return
  
  # Animation loop
  onFrame = (timestamp) ->
    requestAnimationFrame(onFrame)
    return
  
  requestAnimationFrame(onFrame)
  
  # MIDI controller
  launchpad = new Launchpad () ->
    for i in [0...8]
      for j in [0...8]
        launchpad.updateCell(i, j, 0, 3)
