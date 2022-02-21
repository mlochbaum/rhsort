# Robin Hood Sort: the algorithm for uniform data

Robin Hood Sort is a stable integer sorting algorithm that achieves performance several times better than the state of the art on uniformly random arrays, with worst-case performance similar to a hybrid merge sort.

    Best    Average            Worst      Memory     Stable     Deterministic
    n       n log log log n    n log n    n          Yes        Yes

The version given here is not well-tested, is only written for 4-byte integers, and will definitely fail on arrays containing the maximum possible integer. Please don't use it directly. The main purpose of this repository is to show the radix sort people that a great benchmark on random data doesn't mean much. The main purpose of Robin Hood sort is to be used as a possible base case in quicksort algorithms like fluxsort and pdqsort, in order to take advantage of ranges where a uniform distribution seems likely and beat those radix sorts once and for all.

Compared below are merge sort [quadsort](https://github.com/scandum/quadsort), top-of-the-line hybrid quicksorts [pdqsort](https://github.com/orlp/pdqsort) and [fluxsort](https://github.com/scandum/fluxsort), and radix sorts [wolfsort](https://github.com/scandum/wolfsort) (also a bit of a hybrid) and [ska_sort](https://probablydance.com/2017/01/17/faster-sorting-algorithm-part-2/). If you're wondering, Timsort is no good with integer arrays like this, and single-core IPS⁴o loses to the quicksorts on random data. Run on your machine with `$ ./wolfbench.sh` to download the sorts and build, then `$ ./runwolfbench` to perform the benchmark.

![Performance bar chart](images/wolf.svg)

So Robin Hood is tested against the fastest sorting algorithms I know, on wolfsort's own benchmark suite. On the headline benchmark, there's no contest! Surprised? Well, Robin Hood is very skilled—don't forget it—but his greatest skill is cheating.

*Don't worry too much about the bad cases, unless of course you want to use RH on its own, which you shouldn't. Flux/wolfsort have a special analysis pass to use quadsort for most of these, and "generic order" uses a small range, which can easily be detected and obliterated by counting sort. "ascending tiles" hints at a more significant problem, which is that the range can be split into several small clusters. When hybridized with quicksort, it should mostly be possible to rule these cases out during median selection, and quicksort partitioning naturally splits off clusters, which could then be passed to RH.*

### Algorithm

The main idea of Robin Hood Sort is to allocate a buffer a few times larger than the array to be sorted, then send each entry to the appropriate position in the buffer for its value (to get this position, subtract the minimum value, then bitshift). If there's no room in that spot, move entries forward to find space for it, keeping everything in sorted order (that is, place the new entry after any smaller or equal ones, shifting larger ones forward by 1 to make room). Afterwards, the entries are put back in the list with branchless filtering to remove the gaps. The algorithm is named for [Robin Hood hashing](https://programming.guide/robin-hood-hashing.html), which does exactly the same thing to find space for hashes within a hash table. In fact, as Paul Khuong [writes](https://pvk.ca/Blog/2019/09/29/a-couple-of-probabilistic-worst-case-bounds-for-robin-hood-linear-probing/), "I like to think of Robin Hood hash tables with linear probing as arrays sorted on uniformly distributed keys, with gaps". The name for RH hashing comes from the idea that those shifted entries are "rich" because they got there first, and the new entry gets to rob a space from them. I don't think this is the best metaphor, [as I explained](https://youtu.be/paxIkKBzqBU?t=1340) in a talk on searching.

Robin Hood hashing works on the assumption the hashes are uniformly distributed. But the real Robin Hood doesn't live in some kind of communist utopia. Robin Hood Sort works even in non-ideal conditions. The strategy is that when an area gets particularly rich in array values, some of them are scooped up and moved back to the beginning of the original array, which we're not using any more. These stolen values will later be merged—hey, you know, this is much more like Robin Hood than that other part. Let's pretend this is where the name comes from. Anyway, once all the entries from the original array have been placed, the remaining ones from the buffer are moved back, after the stolen ones. Then the stolen values are merged (as in merge sort) with each other, and one last merge with the remaining values completes the sort.

Stealing happens after a value is inserted to the buffer. It's triggered based on the number of positions touched, starting at the target position and ending at the last value pushed out of the way. The simplest form is to move the entire chain. This starts at the first nonempty value, possibly before the target position, to avoid moving a value before one that's equal to it and breaking stability (besides, stealing more values is faster overall). But a modification speeds things up: round down to the nearest multiple of a configurable block size, which is a power of two. Then because every block is sorted, the first few passes of merge sorting on stolen values can be skipped. Since chains in the buffer are constructed by a process that's basically like insertion sort, we should expect overall performance in the worst case to resemble a hybrid merge sort, where smaller merges are skipped in favor of insertion sort. Here, the block size is set to 16. The initial threshold for stealing is twice the block size, because merging any number of stolen values with the rest of the array is costly, and it's reduced to the block size the first time any values are stolen.

### Analysis

Here we'll show that Robin Hood Sort can achieve O(n log log log n) *average* time on random arrays with range at least twice the length (for smaller ranges, use counting/bucket sort and get guaranteed O(n) time), and O(n log(n)) worst-case time. The average case has three logs, which is quite a lot: sorting a quadrillion elements? Oh, that'll cost you an extra factor of 1.26. For practical purposes RH should be considered linear-time on random data.

Here are the steps we need to consider:
* Find the minimum and maximum
* Initialize the buffer
* Insert to the buffer
* Move/filter elements back from the buffer
* Merge sort stolen blocks
* Final merge

In fact, every step of this except the merge sort is O(n). This is obvious for the range-finding and final merge, as they're done in one pass. Same for initializing and filtering the buffer, provided the length of the buffer is O(n). But it's at most `4*n` by construction, so that's handled. The only parts left are the buffer insertion, and that merge sort.

It's not obvious, but buffer insertion is kept to O(n b) by the block-stealing mechanism. When a value is inserted, it could touch any number of positions in the buffer. But if this number is greater than some fixed threshold `b`, some values will be removed. Let's split the cost into two parts: cost pertaining to values that stay, and to values that are then stolen. Less than `b` values can stay on each insertion, so this portion of the cost is under `n*b` entries. And each value can be removed only once, so the total cost pertaining to removed values is proportional to `n`. The sum of the two parts is then proportional to `n*b`. Even with a variable `b` as discussed below, it's less than log(n) and doesn't affect the O(n log(n)) worst case.

Merge sort has a well known worst case bound of O(n log n). This is where most of our cost comes from: in the worst case, nearly all values are snatched from the buffer and the cost reaches that bound. However, the expectation for uniform distributions is different: very few blocks should be stolen. To figure out what exactly the consequences are, we need to know something about the statistics of Robin Hood hashing.

#### Average case

The `n log log log n` bound on average time requires setting a variable block size. However, an adequate block size is `log log log n`, meaning that a block size of 16 carries us through to `n = 2^2^2^16`, which is not physically attainable. So rhsort.c doesn't bother to change the block size.

From the [paper introducing Robin Hood hashing](https://cs.uwaterloo.ca/research/tr/1986/CS-86-14.pdf), the probability that a search in a table with load factor `α` probes at least `i` entries is `pᵢ(α)`, satisfying

    p₁(α) = 1
    pᵢ₊₁(α) = 1 - ((1-α)/α) * (e^(α*(p₁(α)+…+pᵢ(α))) - 1)

Fixing our maximum load factor of `α = 1/2` and doing a lot of math, this reduces to the following recurrence, where the error term `eᵢ` gives the distance from the sum of `pᵢ` to its limit and `expm1(x) := e^x - 1`.

    pᵢ = -2*expm1(eᵢ)
    e₁ = -ln(2)
    eᵢ₊₁ = eᵢ-expm1(eᵢ)

Expanding that last, `x-expm1(x)` is `(1+x) - e^x`. This function maintains the invariant `-1 < eᵢ < 0`, and on this interval it's closer to zero than the function `f(x) = -x²/2`. Consequently, `(-eᵢ) < 2^-(2^i)` for large enough `i`, specifically `i>1`, and `pᵢ < 2*-eᵢ` satisfies `pᵢ < 2^-(2^i)`, this time for `i>2`.

So the probability that a probe of length `b` is performed is `2^-2^b`, and this should mean that the total size of moved blocks is `n*b*2^-2^b` (I haven't proved the validity of going from probe lengths to blocks moved here, but it seems very likely). Setting `b = log₂(log₂(log₂(n)))`, `2^-2^b` is `2^-log(log(n)) = 1/log(n)`, giving size of `n*b/log n`. Now the total asymptotic cost is the cost of insertions plus the cost of merge sorting those blocks:

    cost = n*b + (n*b/log n)log(n*b/log n)
         < n*b + (n*b/log n)log(n)
         = n*b + n*b
         = 2 * n * log log log n

And that's our average-case performance bound!
