// Generated by CoffeeScript 1.7.1
(function() {
  var Sample, audioContext, c, canvas, demoSample, hammer, onFrame;

  window.requestAnimationFrame = window.requestAnimationFrame || window.mozRequestAnimationFrame || window.webkitRequestAnimationFrame || window.msRequestAnimationFrame;

  canvas = document.getElementById("c");

  canvas.width = 500;

  canvas.height = 500;

  c = canvas.getContext("2d");

  hammer = Hammer(window.document.body).on("tap", function(event) {
    console.log("tap");
    demoSample.stop();
  });

  audioContext = new AudioContext();

  Sample = (function() {
    function Sample(url, onReady) {
      var data, source;
      data = null;
      source = null;
      this.load(url);
      this.onReady = onReady;
    }

    Sample.prototype.load = function(url) {
      var request;
      request = new XMLHttpRequest();
      request.open("GET", url, true);
      request.responseType = "arraybuffer";
      request.onload = (function(_this) {
        return function() {
          return audioContext.decodeAudioData(request.response, function(buffer) {
            _this.data = buffer;
            return _this.onReady();
          });
        };
      })(this);
      return request.send();
    };

    Sample.prototype.play = function(time, offset, duration) {
      if (time == null) {
        time = 0;
      }
      if (offset == null) {
        offset = 0;
      }
      this.source = audioContext.createBufferSource();
      this.source.buffer = this.data;
      this.source.connect(audioContext.destination);
      console.log(duration);
      return this.source.start(time, offset, duration);
    };

    Sample.prototype.stop = function(time) {
      if (time == null) {
        time = 0;
      }
      return this.source.stop(time);
    };

    Sample.prototype.drawOn = function(canvas) {
      var amp, data, height, i, step, width, _i;
      width = canvas.width;
      height = canvas.height;
      data = this.data.getChannelData(0);
      step = Math.ceil(data.length / width);
      amp = 200;
      c = canvas.getContext("2d");
      c.beginPath();
      c.moveTo(0, height / 2 + data[0]);
      for (i = _i = 0; 0 <= width ? _i <= width : _i >= width; i = 0 <= width ? ++_i : --_i) {
        c.lineTo(i, height / 2 + data[step * i] * amp);
      }
      c.closePath();
      return c.stroke();
    };

    return Sample;

  })();

  demoSample = new Sample("samples/demo.wav", function() {
    this.drawOn(canvas);
    this.play(0, 3);
  });

  onFrame = function(timestamp) {
    requestAnimationFrame(onFrame);
  };

}).call(this);