// Statistical (Monte Carlo) analysis of Robin Hood criterion

#include <stdlib.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <time.h>

#include "rhsort.c"

int cmpi(const void * ap, const void * bp) {
  T a=*(T*)ap, b=*(T*)bp;
  return (a>b) - (a<b);
}

static U monoclock(void) {
  struct timespec ts;
  clock_gettime(CLOCK_MONOTONIC, &ts);
  return 1000000000*ts.tv_sec + ts.tv_nsec;
}

// Random generator extracted from https://github.com/wangyi-fudan/wyhash
static void _wymum(uint64_t *A, uint64_t *B){ __uint128_t r=*A; r*=*B; *A=(uint64_t)r; *B=(uint64_t)(r>>64); }
static uint64_t _wymix(uint64_t A, uint64_t B){ _wymum(&A,&B); return A^B; }
static uint64_t wyrand(uint64_t *seed){ *seed+=0xa0761d6478bd642full; return _wymix(*seed,*seed^0xe7037ed1a0b428dbull);}
static uint64_t wy2u0k(uint64_t r, uint64_t k){ _wymum(&r,&k); return k; }
#define RAND(range) wy2u0k(wyrand(&seed), range)

// Floyd to get sorted sample of k indices < n
// O(n^2) because it insertion sorts
void sample(U *out, U k, U n, uint64_t *seedp) {
  uint64_t seed = *seedp;
  for (U i=0; i<k; i++) {
    U max=n-k+i, r=RAND(max+1);
    U j=0;
    while (j<i && out[j]<r) j++;
    if (j<i && out[j]==r) {
      out[i] = max;
    } else {
      for (U t=i; t>j; t--) out[t]=out[t-1];
      out[j]=r;
    }
  }
  *seedp = seed;
}

// Maximum segments for piecewise-linear distribution
#define MAX_SEGS 32

// Generate an input with a random piecewise-linear distribution
void genseq(uint64_t seed, T *array, U len) {
  T min = (T)wyrand(&seed), max = (T)wyrand(&seed);
  if (max<min) { T t=min; min=max; max=t; }
  U range = (unsigned)(max-min);
  U unique = 1 << (7+RAND(20));

  U points[4*MAX_SEGS];
  U l = RAND(MAX_SEGS);     if (l<2) l=2;  // Segments to generate
  U r = RAND(MAX_SEGS) / l; if (r<1) r=1;  // Repetitions
  U rl = r*l;

  // Make partitions of the n values into rl possibly-empty segments
  for (U io=0; io<2; io++) {
    U *p = points + io*MAX_SEGS;
    U n = io ? range : unique;
    U m = n/r - 1;
    sample(p, l-1, m+(l-1), &seed);
    p[l-1] = m+l;
    // Differences minus 1
    U prev = 0;
    for (U i=0; i<l; i++) {
      U new = p[i];
      p[i] = new - prev;
      prev = new + 1;
    }
    // Handle reps
    for (U i=l; i<rl; i++) p[i] = p[i-l];
    for (U i=0; i<n-r*(m+1); i++) p[i]++;
    // Also get the running (exclusive) sum
    U *s = p + 2*MAX_SEGS;
    for (U i=0, t=0; i<rl; i++) {
      s[i] = t;
      t += p[i];
    }
  }

  // Generate results
  U *size_in  = points,
         *size_out = points + 1*MAX_SEGS,
         *pos_in   = points + 2*MAX_SEGS,
         *pos_out  = points + 3*MAX_SEGS;
  for (U i=0; i<len; i++) {
    U u = RAND(unique);

    // Locate segment
    U seg = 0;
    for (U n=rl, h; h=n/2; n-=h) {
        U mid = seg + h;
        seg = pos_in[mid] <= u ? mid : seg;
    }

    array[i] = pos_out[seg] + (u - pos_in[seg])*size_out[seg]/size_in[seg];
  }
}

// Return RH criterion value with a sample of c candidates
U rhcrit(T *x, U n, U c, U seed) {
  // Find the range.
  T min=x[0], max=min;
  for (U i=1; i<n; i++) {
    T e=x[i]; if (e<min) min=e; if (e>max) max=e;
  }
  U r = (U)(UT)(max-min) + 1;           // Size of range

  // Counting sort handled separately
  if (r/4 < n) return 0;

  U sh = 0;                             // Contract to fit range
  while (r>5*n) { sh++; r>>=1; }        // Shrink to stay at O(n) memory

  U score = 0;
  T s[c]; // Sample
  for (U i=0; i<c; i++) s[i]=x[RAND(n)];
  qsort(s, c, sizeof(T), cmpi);
  #define POS(E) ((U)(UT)((E)-min) >> sh)
  for (U i=1, prev=POS(s[i-1]); i<c; i++) {
    U next=POS(s[i]), o=1, d=next-prev; prev=next;
    while (d<16) { score+=16-d; if (++o>i) break; d=next-POS(s[i-o]); }
  }
  #undef POS
  return score;
}

int main(int argc, char **argv) {
  U n = 10000, cand = 100, iter = 200, checks = 1+10*100;
  U rounds = argc>1 ? atoi(argv[1]) : 150;
  printf("Checking %ld candidates out of %ld values\n", cand, n);
  U s = n*sizeof(T), si=(n+iter-1)*sizeof(T);
  T *data = malloc(si), // Saved random data
    *sort = malloc(si), // Array to be sorted
    *chk  = malloc(si); // For checking with qsort
  T *crs  = malloc(checks*sizeof(T)); // Criterion sample results
  for (U k=0; k<rounds; k++) {
    uint64_t seed = 101+11*k;
    printf("Testing seed %4ld: ", seed);
    genseq(seed, data, n+iter-1);
    for (U i=0; i<checks; i++) crs[i]=rhcrit(data, n, cand, n+i);
    qsort(crs, checks, sizeof(T), cmpi);
    for (U i=0; i<checks; i+=checks/10) printf("%4ld ",crs[i]);
    // Test
#ifndef NOTEST
    memcpy(sort, data, s); rhsort32(sort, n);
    memcpy(chk , data, s); qsort(chk, n, sizeof(T), cmpi);
    for (U i=0; i<n; i++) if (sort[i]!=chk[i]) {
      printf("Fails at [%ld]: %d but should be %d! ", i, sort[i], chk[i]);
      break;
    }
#endif
    // Time
    U sum=0, best=0;
    for (U r=0; r<iter; r++) {
      memcpy(sort, data+r, s);
      U t = monoclock();
      rhsort32(sort, n);
      t = monoclock()-t;
      sum += t;
      if (r==0||t<best) best=t;
    }
    printf("best:%7.3f avg:%7.3f ns/v", (double)best/n, (double)sum/(iter*n));
    printf("\n");
  }
  return 0;
}
