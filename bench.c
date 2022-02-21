#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>

#include "rhsort.c"

void merge32(T *x, U n) {
  T *aux = malloc(n*sizeof(T));
  for (U w=1; w<n; w*=2)
    for (U i=0, ww=2*w; i<n-w; i+=ww)
      merge(x+i, w, n-i<ww?n-i:ww, aux);
  free(aux);
}

// For qsort
int cmpi(const void * a, const void * b) {
	return *(T*)a - *(T*)b;
}

void main(int argc, char **argv) {
  // Command-line arguments are max or min,max
  // Inclusive range, with sizes 10^n tested
  U min=3, max=6;
  if (argc>1) {
    max=atoi(argv[argc-1]);
    if (argc>2) min=atoi(argv[argc-2]);
  }

  U sizes[max+1];
  for (U k=0,n=1; k<=max; k++,n*=10) sizes[k]=n;

  U s = sizes[max]*sizeof(T);
  T *data = malloc(s), // Saved random data
    *sort = malloc(s), // Array to be sorted
    *chk  = malloc(s); // For checking with qsort
  srand(time(NULL));
  for (U k=min, n=0; k<=max; k++) {
    for (U e=sizes[k]; n<e; n++) data[n]=rand();
    s = n*sizeof(T);
    printf("Testing size %8d: ", n);
    // Test
    memcpy(sort, data, s); rhsort32(sort, n);
    memcpy(chk , data, s);  qsort  (chk , n, sizeof(T), cmpi);
    for (U i=0; i<n; i++) if (sort[i]!=chk[i]) {
      printf("Fails at [%d]: %d but should be %d! ", i, sort[i], chk[i]);
      break;
    }
    // Time
    U iter = 1+2000000/n;
    clock_t sum=0, best=0;
    for (U r=0; r<iter; r++) {
      memcpy(sort, data, s);
      clock_t t = clock();
      rhsort32(sort, n);
      t = clock()-t;
      sum += t;
      if (r==0||t<best) best=t;
    }
    printf("best: %f avg: %f", (double)best/CLOCKS_PER_SEC, (double)sum/(iter*CLOCKS_PER_SEC));
    printf("\n");
  }
}
