#include <stdlib.h>
#include <string.h>

typedef int T;
typedef size_t U;
#define LIKELY(X) __builtin_expect(X,1)
#define RARE(X) __builtin_expect(X,0)

const U BLOCK = 16;

void merge(T *a, U l, U n, T *aux) {
  if (a[l-1] <= a[l]) return;
  if (a[n-1] < a[0] && l+l==n) {
    T *b = a+l;
    for (U i=0; i<l; i++) { T t=a[i]; a[i]=b[i]; b[i]=t; }
    return;
  }
  memcpy(aux, a, l*sizeof(T));
  for (U ai=0, bi=l, i=0; i<bi; i++) {
    if (bi>=n || aux[ai]<=a[bi])
      a[i] = aux[ai++];
    else 
      a[i] = a[bi++];
  }
}

void rhsort32(void *array, U n) {
  T *x = array, *xb=x;
  T min=x[0], max=min;
  for (U i=1; i<n; i++) {
    T e=x[i]; if (e<min) min=e; if (e>max) max=e;
  }
  T s = max+1;
  U r = (U)(unsigned int)(max-min) + 1;
  U sh = 0;
  while (r>4*n) { sh++; r>>=1; }
  U threshold = 2*BLOCK;
  U sz = r + threshold;
  T *aux = malloc((sz>n?sz:n)*sizeof(T)); // >=n for merges later
  for (U i=0; i<sz; i++) aux[i] = s;
  #define POS(E) ((U)((E)-min) >> sh)
  for (U i=0; i<n; i++) {
    T e = x[i];
    U j = POS(e), j0=j, f=j;
    T h = aux[f];
    if (LIKELY(h==s)) { aux[f]=e; continue; }
    // Collision: find size of chain and position in it
    do {
      j += e>=h;
      h = aux[++f];
    } while (RARE(h!=s));
    for (U t=f; t>j; t--) aux[t] = aux[t-1];
    aux[j]=e;
    f += 1;
    // Bad collision: send chain back to x
    if (RARE(f-j0 >= threshold)) {
      threshold = BLOCK;
      for (U i=j0; i<f; i++) { *xb++=aux[i]; aux[i]=s; }
    }
  }
  #undef POS
  while (aux[--sz] == s); sz++;
  T *xt=xb;
  for (U i=0; i<sz; i++) if ((*xt=aux[i])!=s) xt++;
  U l = xb-x;
  if (l) {
    // Sort x[0..l]
    for (U w=1; w<l; w*=2)
      for (U i=0, ww=2*w; i<l-w; i+=ww)
        merge(x+i, w, l-i<ww?l-i:ww, aux);
    // And merge with the rest of x
    merge(x, l, n, aux);
  }
  free(aux);
}
