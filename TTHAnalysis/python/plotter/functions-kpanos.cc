
float f_MET_JPsi(float met, float mll) {
  if (mll > 2.5 && mll < 3.5)
    return met;
  else
    return -99;
}
