window.requestAnimationFrame =
  window.requestAnimationFrame or
  window.mozRequestAnimationFrame or
  window.webkitRequestAnimationFrame or
  window.msRequestAnimationFrame

canvas = document.getElementById "c"
canvas.width = 500
canvas.height = 500
c = canvas.getContext "2d"

hammer = Hammer(window.document.body).on "tap", (event) ->
  console.log "tap"
  demoSample.stop()
  return

audioContext = new AudioContext()

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
    console.log(duration)
    @source.start(time, offset, duration)

  stop: (time=0) ->
    @source.stop(time)
            
  drawOn: (canvas) ->
    width = canvas.width
    height = canvas.height
    data = @data.getChannelData(0)
    step = Math.ceil(data.length / width)
    amp = 200
    c = canvas.getContext "2d"
    c.beginPath()
    c.moveTo(0, height/2 + data[0])
    for i in [0..width]
      c.lineTo(i, height/2 + data[step*i] * amp)
    c.closePath()
    c.stroke()

demoSample = new Sample "samples/demo.wav", () ->
  @drawOn(canvas)
  @play(0, 3)
  return

onFrame = (timestamp) ->
  requestAnimationFrame(onFrame)
  return

#requestAnimationFrame(onFrame)
