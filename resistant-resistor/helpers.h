#define ANALOG_MAX 1023

double linlin(double val, double inMin, double inMax, double outMin,
              double outMax, bool clamp = true)
{
  if (clamp) {
    if (val <= inMin) return outMin;
    if (val >= inMax) return outMax;
  }
  const double inRange = inMax - inMin;
  const double norm = (val - inMin) / inRange;
  const double outRange = outMax - outMin;
  const double scaled = norm * outRange;
  return scaled + outMin;
}

double lincurve(double val, double inMin, double inMax, double outMin,
                double outMax, double curve, bool clamp = true) {
  if (clamp) {
    if (val <= inMin) return outMin;
    if (val >= inMax) return outMax;
  }

  if (fabs(curve) < 0.001) {
    // clamping would have happened above, no need to do check within linlin
    return linlin(val, inMin, inMax, outMin, outMax, false);
  }

  const double grow = exp(curve);
  const double a = (outMax - outMin) / (1.0 - grow);
  const double b = outMin + a;
  const double scaled = (val - inMin) / (inMax - inMin);

  return b - (a * pow(grow, scaled));
}
