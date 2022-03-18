#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>

// Options for sorting algorithms:
#if QUADSORT
  #define sortname "quadsort"
#elif FLUXSORT
  #define sortname "fluxsort"
#elif WOLFSORT
  #define sortname "wolfsort"
#elif SKASORT
  #define sortname "ska_sort"
#elif SKACOPY
  #define sortname "ska_sort_copy"
#elif PDQSORT
  #define sortname "pdqsort"
#elif MERGESORT
  #define sortname "mergesort"
#elif RHMERGESORT
  #define sortname "rhmergesort"
#else
  #define sortname "rhsort"
#endif

#if QUADMERGE
  #define quadness "quad+"
#else
  #define quadness ""
#endif

#if BRAVE
  #define bravery "brave+"
#else
  #define bravery ""
#endif

// Options for test to perform:
#if RANGES  // Small range
  #define datadesc "10,000 small-range 4-byte integers"
#elif WORST // RH worst case
  #define datadesc "small-range plus outlier"
#else       // Random
  #define datadesc "random 4-byte integers"
#endif

#if WORST
  #define MODIFY(arr) arr[0] = 3<<28
#else
  #define MODIFY(arr) (void)0
#endif

typedef size_t U;
static U monoclock(void) {
  struct timespec ts;
  clock_gettime(CLOCK_MONOTONIC, &ts);
  return 1000000000*ts.tv_sec + ts.tv_nsec;
}

#if PROFILE
#define PROFLEN 10
static U profsums[PROFLEN];
#define PROF_INIT memset(profsums, 0, sizeof(profsums))
#define PROF_START(n) U proft##n = monoclock()
#define PROF_CONT(n)    proft##n = monoclock()
#define PROF_END(n)   profsums[n] += monoclock()-proft##n
static void printprof(U denom) {
  U l=PROFLEN; while (l && profsums[l-1]==0) l--;
  printf(" profile");
  for (U i=0; i<l; i++) printf("%7.3f", (double)profsums[i]/denom);
}
#else
#define PROF_INIT (void)0
#define printprof(n) (void)0
#endif

#include "rhsort.c"

#if QUADSORT || FLUXSORT || WOLFSORT
#define cmp(a,b) (*(a) > *(b))
#include "wolfsort/src/quadsort.h"
#endif

#if FLUXSORT || WOLFSORT
#include "wolfsort/src/fluxsort.h"
#endif

#if WOLFSORT
#include "wolfsort/src/wolfsort.h"
#elif PDQSORT
#include "wolfsort/src/pdqsort.h"
#elif SKASORT || SKACOPY
#include "wolfsort/src/ska_sort.hpp"
#endif

static void sort32(T *x, U n) {
#if QUADSORT
  quadsort32(x, n, NULL);
#elif FLUXSORT
  fluxsort32(x, n, NULL);
#elif WOLFSORT
  wolfsort(x, n, 4, NULL);
#elif SKASORT
  ska_sort(x, x+n);
#elif SKACOPY
  T *aux = malloc(n*sizeof(T));
  ska_sort_copy(x, x+n, aux);
  free(aux);
#elif PDQSORT
  pdqsort(x, x+n);
#elif MERGESORT
  T *aux = malloc(n*sizeof(T));
  mergefrom(x, n, 1, aux);
  free(aux);
#elif RHMERGESORT
  rhmergesort32(x, n);
#else
  rhsort32(x, n);
#endif
}

// For qsort
int cmpi(const void * ap, const void * bp) {
  T a=*(T*)ap, b=*(T*)bp;
  return (a>b) - (a<b);
}

#ifndef RANGES
static U n_iter(U n) { return 1+3000000/(20+n); }
#else
static U n_iter(U n) { return 1000; }
#endif

int main(int argc, char **argv) {
  printf("Sorting %s: %s%s%s\n", datadesc, bravery, quadness, sortname);
  // Command-line arguments are max or min,max
  // Inclusive range, with sizes 10^n tested
  U min=3, max=6; int ls=0;
  if (argc>1) {
    ls = argv[1][0]=='l';
    if (ls) {
      // Log line chart 100 to 1e7 with 44 points, plus 4 before for warmup
      min=0;
      max = (argc>2) ? atoi(argv[2]) : 48;
    } else {
      max=atoi(argv[argc-1]);
      if (argc>2) min=atoi(argv[argc-2]);
    }
  }

  U sizes[max+1];
  if (!ls) { for (U k=0,n=1 ; k<=max; k++,n*=10) sizes[k]=n; }
  else     { for (U k=0,n=34; k<=max; k++,n=n*1.3+(n<70)) sizes[k]=n; if(max==48)sizes[max]=10000000; }

#ifndef RANGES
  U s=sizes[max]; s+=n_iter(s)-1;
  U q=sizes[min]; q+=n_iter(q)-1; if (s<q) s=q;
#else
  U s=10000; s+=n_iter(s)-1;
#endif
  s*=sizeof(T);
  T *data = malloc(s), // Saved random data
    *sort = malloc(s), // Array to be sorted
    *chk  = malloc(s); // For checking with qsort
  srand(time(NULL));
  for (U k=min, m=0; k<=max; k++) {
    U n = sizes[k];
    U iter = n_iter(n), off = max-k;
#if RANGES
    n=10000; m=0;
#endif
    for (U e=n+off+iter-1; m<e; m++) {
#if WORST
      data[m]=rand()%1024;
#elif RANGES
      data[m]=rand()%sizes[k];
#else
      data[m]=rand();
#endif
    }
    s = n*sizeof(T);
#if RANGES
    printf("Testing range %8ld: ", sizes[k]);
#else
    printf("Testing size %8ld: ", n);
#endif
    // Test
#ifndef NOTEST
    memcpy(sort, data, s); MODIFY(sort); sort32(sort, n);
    memcpy(chk , data, s); MODIFY(chk ); qsort(chk, n, sizeof(T), cmpi);
    for (U i=0; i<n; i++) if (sort[i]!=chk[i]) {
      printf("Fails at [%ld]: %d but should be %d! ", i, sort[i], chk[i]);
      break;
    }
#endif
    // Time
    U sum=0, best=0;
    PROF_INIT;
    for (U r=0; r<iter; r++) {
      memcpy(sort, data+off+r, s); MODIFY(sort);
      U t = monoclock();
      sort32(sort, n);
      t = monoclock()-t;
      sum += t;
      if (r==0||t<best) best=t;
    }
    printf("best:%7.3f avg:%7.3f ns/v", (double)best/n, (double)sum/(iter*n));
    printprof(iter*n);
    printf("\n");
  }
  return 0;
}
