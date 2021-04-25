#include "rand.h"

static qword_t const mul = 6364136223846793005ull;
static qword_t const inc = 1442695040888963407ull;

static qword_t s = 15217075127098281625ull;

void rand_seed(qword_t seed) {
  s = 0;
  rand_next();
  s += seed;
  rand_next();
}

dword_t rand_next(void) {
  dword_t x, r;
  x = (dword_t)(((s >> 18) ^ s) >> 27);
  r = (dword_t)(s >> 59);
  s *= mul;
  s += inc;
  return (x >> r) | (x << ((-r) & 31));
}
