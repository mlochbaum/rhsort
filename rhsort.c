#include <stdlib.h>
#include <string.h>

typedef int T;
typedef unsigned int UT;
typedef size_t U;
#define LIKELY(X) __builtin_expect(X,1)
#define RARE(X) __builtin_expect(X,0)

// Minimum size to steal from buffer
static const U BLOCK = 16;

// Merge arrays of length l and n-l starting at a, using buffer aux.
static void merge(T *a, U l, U n, T *aux) {
  // Easy cases when the merge can be avoided
  // If the buffer helping at all, most merges go through these
  if (a[l-1] <= a[l]) return;
  if (a[n-1] < a[0] && l+l==n) {
    T *b = a+l;
    for (U i=0; i<l; i++) { T t=a[i]; a[i]=b[i]; b[i]=t; }
    return;
  }
  // Ordinary merge code, not fast or anything
  memcpy(aux, a, l*sizeof(T));
  for (U ai=0, bi=l, i=0; i<bi; i++) {
    if (bi>=n || aux[ai]<=a[bi])
      a[i] = aux[ai++];
    else 
      a[i] = a[bi++];
  }
}

// Counting sort of the n values starting at x
// This is the basic version: fast for small ranges
// There are better strategies as the range gets close to n
static void count(T *x, U n, T min, U range) {
  U *count = malloc(range*sizeof(U));
  memset(count, 0, range*sizeof(U));
  // Count the values
  for (U i=0; i<n; i++) count[x[i]-min]++;
  // Write based on the counts
  for (U i=0; i<range; i++)
    for (U j=0; j<count[i]; j++)
      *x++ = min+i;
  free(count);
}

// The main attraction. Sort array of ints with length n.
void rhsort32(T *array, U n) {
  T *x = array, *xb=x;  // Stolen blocks go to xb

  // Find the range.
  T min=x[0], max=min;
  for (U i=1; i<n; i++) {
    T e=x[i]; if (e<min) min=e; if (e>max) max=e;
  }
  U r = (U)(UT)(max-min) + 1;           // Size of range
  if (RARE(r <= 2*n)) {                 // Counting sort if it's small
    return count(x, n, min, r);
  }

  // Planning for the buffer
  T s = max+1;                          // Sentinel value
  U sh = 0;                             // Contract to fit range
  while (r>5*n) { sh++; r>>=1; }        // Shrink to stay at O(n) memory
  // Goes down to BLOCK once we know we have to merge
  U threshold = 2*BLOCK;
  U sz = r + threshold;                 // Buffer size

  // Allocate buffer, and fill with sentinels
  T *aux = malloc((sz>n?sz:n)*sizeof(T)); // >=n for merges later
  for (U i=0; i<sz; i++) aux[i] = s;

  // Main loop: insert array entries into buffer
  #define POS(E) ((U)((E)-min) >> sh)
  for (U i=0; i<n; i++) {
    T e = x[i];               // Entry to be inserted
    U j = POS(e);             // Target position
    T h = aux[j];             // What's there?
    // Common case is that it's empty (marked with sentinel s)
    if (LIKELY(h==s)) { aux[j]=e; continue; }

    // Collision: find size of chain and position in it
    U j0=j, f=j;
    do {
      j += e>=h;          // If we have to move past that entry
      h = aux[++f];       // Next one
    } while (RARE(h!=s)); // Until the end of the chain
    // We'll insert at j. Move the values after that one forward.
    for (U t=f; t>j; t--) aux[t] = aux[t-1];
    aux[j]=e;
    f += 1;  // To account for just-inserted e

    // Bad collision: send chain back to x
    if (RARE(f-j0 >= threshold)) {
      threshold = BLOCK;
      // Find the beginning of the chain (required for stability)
      while (j0 && aux[j0-1]!=s) j0--;
      // Move as many blocks from it as possible
      T *hj = aux+j0, *hf = aux+f;
      while (hj <= hf-BLOCK) {
        for (U i=0; i<BLOCK; i++) { xb[i]=hj[i]; hj[i]=s; }
        hj += BLOCK; xb += BLOCK;
      }
      // Leftover elements might have to move backwards
      U pr = j0;
      while (hj < hf) {
        e = *hj; *hj++ = s;
        U pp = POS(e);
        pr = pp>pr ? pp : pr;
        aux[pr++] = e;
      }
    }
  }
  #undef POS

  // Move all values from the buffer back to the array
  // Use xt += to convince the compiler to make it branchless
  while (aux[--sz] == s); sz++;
  T *xt=xb; for (U i=0; i<sz; i++) xt += s!=(*xt=aux[i]);

  // Merge stolen blocks back in if necessary
  U l = xb-x;  // Size of those blocks
  if (l) {
    // Sort x[0..l]
    for (U w=BLOCK; w<l; w*=2)
      for (U i=0, ww=2*w; i<l-w; i+=ww)
        merge(x+i, w, l-i<ww?l-i:ww, aux);
    // And merge with the rest of x
    merge(x, l, n, aux);
  }
  free(aux);  // All done!
}
