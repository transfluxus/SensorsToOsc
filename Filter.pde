boolean doFilter = false;

void setupFilter() {
  filter =  new SignalFilter(this, NUMBER_OF_INPUT_VALUES);
}

void applyFilter() {
  if (doFilter) {       // bye bye for now
    float[] noisyValues = new float[NUMBER_OF_INPUT_VALUES];
    for (int i=0; i < NUMBER_OF_INPUT_VALUES; i++) {
      noisyValues[i] = (float)sensors[i].value / maxAnalogValue;
    }
    float[] filteredValues = filter.filterUnitArray(noisyValues);
    for (int i=0; i < NUMBER_OF_INPUT_VALUES; i++) {
      sensors[i].value = (int)(filteredValues[i] * maxAnalogValue);
    }
  }
}