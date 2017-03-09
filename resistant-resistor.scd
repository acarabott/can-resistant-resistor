"echo '%' | pbcopy".format(SerialPort.devices.last).unixCmd
~serial.close

(
~serial = SerialPort(
  "/dev/tty.usbmodem14411",
  baudrate: 9600,
  crtscts: true
);

~millis = 0;
~potValue = 0;
~servoValue = 0;
~potMax = 990;

)


Tdef(\serial, {
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
      ~servoValue  = if(servoValue.isNil) { ~servoValue } { servoValue.asFloat };
    };
    (1/60).wait;
  }
}).play();

(
~ensureDecimalStr = {|num|
  var str = num.asString;
  if(str.includes($.)) { str } { str ++ ".0" };
};

~setCurve = {|splitPct, curve|
  var splitStr = splitPct;
  var curveStr = curve;

  ~splitPct = splitPct;
  ~curve = curve;

  {~serial.putAll("%, %".format(splitStr, curveStr))}.fork;
};
~setCurve.(0.5, -2);

~servoFunc = {|input, min, max, splitPct|
  var range = max - min;
  var splitVal = range * splitPct;
  var splitPoint = min + splitVal;
  if (input <= splitPoint) {
    input.lincurve(min, splitPoint, 0.0, 1.0, ~curve);
  } {
    input.lincurve(splitPoint, max, 1.0, 0.0, ~curve.neg);
  };
};

(
if (~win.notNil) { ~win.close; };
~win = Window("", Rect(80, 200, 1200, 675)).front;
~win.view.background = Color.white;
~canvas = UserView(~win, ~win.bounds.size);
~canvas.background = Color.white;
~canvas.drawFunc = {
  Pen.color = Color(0.17, 0.61, 0.83);
  ~canvas.bounds.width.do {|i|
    var maxHeight = ~canvas.bounds.height;
    var x = i;
    var norm = ~servoFunc.(i, 0, ~canvas.bounds.width, ~splitPct);
    var height = norm * maxHeight;
    var y = maxHeight - height;
    Pen.fillRect(Rect(i, y, 1, height));
    Pen.lineTo(x, y);
  };
  Pen.stroke;
};
)
