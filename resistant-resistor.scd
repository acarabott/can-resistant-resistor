"echo '%' | pbcopy".format(SerialPort.devices.last).unixCmd

(
~serial = SerialPort(
  "/dev/tty.usbmodem14411",
  baudrate: 9600,
  crtscts: true
);
)

~millis = 0;
~potValue = 0;
~servoValue = 0;

Tdef(\serial, {
  var str, byte, split;

  inf.do {|i|
    if(~serial.read == 10) {
      str = "";
      while({ byte = ~serial.read; byte != 13 }, {
        str = str ++ byte.asAscii;
      });

      split = str.split($,);
      ~millis = split[0];
      ~potValue = split[1];
      ~servoValue = split[2];

      // don't remove!
      0.wait;
    };
  }
}).play();


{~serial.putAll("1.0, 4.0")}.fork;
