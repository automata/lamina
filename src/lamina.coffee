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
    @source.start(time, offset, duration)

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
  demoSample.play(0, offsetSeconds)
  demoSample.drawOn(canvas, x)
  return

# Main
demoSample = new Sample "samples/demo.wav", () ->
  @drawOn(canvas)
  @play()
  return

# Animation loop
onFrame = (timestamp) ->
  requestAnimationFrame(onFrame)
  return

#requestAnimationFrame(onFrame)
