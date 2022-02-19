typedef int T;
typedef size_t U;
#define LIKELY(X) __builtin_expect(X,1)
#define RARE(X) __builtin_expect(X,0)

void rhsort32(void *array, U n) {
  T *x = array;
  T min=x[0], max=min;
  for (U i=1; i<n; i++) {
    T e=x[i]; if (e<min) min=e; if (e>max) max=e;
  }
  T s = max+1;
  U r = (U)(unsigned int)(max-min) + 1;
  U sh = 0;
  while (r>4*n) { sh++; r>>=1; }
  U sz = r + 32;
  T *hash = malloc(sz*sizeof(T));
  for (U i=0; i<sz; i++) hash[i] = s;
  for (U i=0; i<n; i++) {
    T e = x[i], h;
    U j = (U)(e-min) >> sh;
    while (RARE(e >= (h=hash[j]))) j++;
    hash[j]=e;
    while (RARE(h!=s)) { j++; T ht=hash[j]; hash[j]=h; h=ht; }
  }
  while (hash[--sz] == s); sz++;
  for (U i = 0; i < sz; i++) if ((*x=hash[i])!=s) x++;
  free(hash);
}
