"echo '%' | pbcopy".format(SerialPort.devices.last).unixCmd
~serial.close

(
~serial = SerialPort(
  "/dev/tty.usbmodem14611",
  baudrate: 9600,
  crtscts: true

MIDIClient.init;
m = MIDIOut.newByName("IAC", "Bus 1");
m.latency = 0.0;

);

~millis = 0;
~potValue = 0;
~servoValue = 0;
~potMax = 990;
~prevMidi = 0;
)

Tdef(\cereal).stop;
Tdef(\cereal, {
  var str, byte, split;

  inf.do {|i|
    var millis, potValue, servoValue;
    if(~serial.read == 10) {
      str = "";
      while({ byte = ~serial.read; byte != 13 }, {
        str = str ++ byte.asAscii;
      });
      split = str.split($,);

      millis = split[0];
      potValue = split[1];
      servoValue = split[2];

      ~millis = if(millis.isNil) { ~millis } { millis.asInt };
      ~potValue = if(potValue.isNil) { ~potValue } { potValue.asFloat };

      ~prevServo = ~servoValue;
      ~servoValue  = if(servoValue.isNil) { ~servoValue } { servoValue.asFloat };
      ~potValue.postln;

      ~prevMidi = ~midi;
      ~midi = ~servoValue.lincurve(0, 1.0, 64, 127, 2).asInt.postln;
      if(~prevMidi != ~midi) {
        m.control(0, 1, ~midi);
      };

    };
    0.05.wait;
  }
}).play;

(
~setCurve = {|splitPct, curve|
  ~splitPct = splitPct;
  ~curve = curve;

  {~serial.putAll("%, %".format(~splitPct, ~curve))}.fork;
};
~setCurve.(50, -2);

~servoFunc = {|input, min, max, splitPct|
  var range = max - min;
  var splitVal = range * (splitPct / 100.0);
  var splitPoint = min + splitVal;
  if (input <= splitPoint) {
    input.lincurve(min, splitPoint, 0.0, 1.0, ~curve);
  } {
    input.lincurve(splitPoint, max, 1.0, 0.0, ~curve.neg);
  };
};
)

(
if (~win.notNil) { ~win.close; };
~winSize = 1200@675;
~win = Window("", Rect((Window.screenBounds.width - ~winSize.x) / 2,
                       (Window.screenBounds.height - ~winSize.y) / 2,
                       ~winSize.x,
                       ~winSize.y)).front;
~win.view.background = Color.white;
~canvas = UserView(~win, ~win.bounds.size);
~canvas.background = Color.white;
~canvas.drawFunc = {
  ~canvas.bounds.width.do {|i|
    var maxHeight = ~canvas.bounds.height;
    var x = i;
    var norm = ~servoFunc.(i, 0, ~canvas.bounds.width, ~splitPct);
    var height = norm * maxHeight;
    var y = maxHeight - height;
    var normx = i / ~canvas.bounds.width;
    Pen.color = if (normx < ~potValue) {
      Color(0.17, 0.61, 0.83, norm.linlin(0, 1, 0.3, 1.0));
      } {
      Color(0.8, 0.8, 0.8);
    };
    Pen.fillRect(Rect(i, y, 1, height));
    Pen.lineTo(x, y);
  };
  Pen.stroke;
};

Tdef(\animation, {
  inf.do {|i|
    {~canvas.refresh;}.fork(AppClock);
    0.01.wait;
  }
}).play(AppClock, quant:Quant(1));

)


Tdef(\miditest).stop
Tdef(\miditest, {
  var max = 64;
  var wait = 0.05;
  inf.do {|i|
    max.do {|i|
      i.postln;
      m.control(0, 0, i);
      wait.wait;
    };
    (max..0).do {|i|
      m.control(0, 0, i);
      wait.wait;
    }

  }
}).play(quant:Quant(1));



~setCurve.(60, 6);
