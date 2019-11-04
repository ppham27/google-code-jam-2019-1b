// Chooses the left-most sword with the most skill.
func reduce(_ a: (value: Int, index: Int),
            _ b: (value: Int, index: Int)) -> (value: Int, index: Int) {
    return a.value > b.value ? a : b;
}

// Creates a table `memo` such that memo[i][j] is the maximum sword over the
// the interval values[i],...,values[i + 2^j - 1].
func memoize<T: Collection>(_ values: T) -> [[(value: Int, index: Int)]]
  where T.Element == Int {
    let N = values.count
    var memo = values.enumerated().map {[(value: $0.element, index: $0.offset)]}
    for j in 1..<(N.bitWidth - N.leadingZeroBitCount) {
        let offset = 1 << (j - 1)
        for i in 0..<N {
            memo[i].append(
              i + offset < N ?
                reduce(memo[i][j - 1], memo[i + offset][j - 1]) : memo[i][j - 1])
        }
    }
    return memo
}

// Uses the table created by `memoize` to perform constant-time range queries.
func queryMax(memo: [[(value: Int, index: Int)]],
              from: Int, to: Int) -> (value: Int, index: Int) {
    let rangeCount = to - from        
    let bitShift = rangeCount.bitWidth - rangeCount.leadingZeroBitCount - 1
    let offset = 1 << bitShift
    return reduce(memo[from][bitShift], memo[to - offset][bitShift])
}

// Finds the first value `x` in the range `[from, to)` such that `test(x)` is
// true. If no such `x` exists, returns `to`.
func search(_ from: Int, _ to: Int, _ test: (_: Int) -> Bool) -> Int {
    if from == to { return from }
    let x = from + (to - from) / 2
    return test(x) ? search(from, x, test) : search(x + 1, to, test)
}

// Counts the the number of fair fights over a specified range.
func countFairFights(K: Int,
                     C: [[(value: Int, index: Int)]],
                     D: [[(value: Int, index: Int)]],
                     from: Int, to: Int) -> Int {
    if from >= to { return 0 }
    // Find all fair fights that contain the pivot.
    let pivot = queryMax(memo: C, from: from, to: to)
    // Intervals that contain the pivot with an opposing max at most K more.
    let L = search(
      from, pivot.index + 1,
      {(x: Int) -> Bool in
          queryMax(memo: D, from: x, to: pivot.index + 1).value <= pivot.value + K
      })
    let R = search(
      pivot.index, to,
      {(x: Int) -> Bool in  // Negate to find exclusive upper bound.
          queryMax(memo: D, from: pivot.index, to: x + 1).value > pivot.value + K
      })
    // Intervals that contain the pivot with an opposing max that is too small.
    let l = search(
      L, pivot.index + 1,
      {(x: Int) -> Bool in
          queryMax(memo: D, from: x, to: pivot.index + 1).value < pivot.value - K
      })
    let r = search(
      pivot.index, R,
      {(x: Int) -> Bool in  // Negate to find exclusive upper bound.
          queryMax(memo: D, from: pivot.index, to: x + 1).value >= pivot.value - K
      })
    return (pivot.index - L + 1) * (R - pivot.index) -
      (pivot.index - l + 1) * (r - pivot.index) +
      countFairFights(K: K, C: C, D: D, from: from, to: pivot.index) +
      countFairFights(K: K, C: C, D: D, from: pivot.index + 1, to: to)
}

// Counts the number of fair fights.
func countFairFights<T: Collection>(K: Int, C: T, D: T) -> Int
  where T.Element == Int {
    return countFairFights(
      K: K, C: memoize(C), D: memoize(D), from: 0, to: max(C.count, D.count))
}

let T = readLine().flatMap { Int($0) }!
for t in 1...T {
    let K = readLine().flatMap { $0.split(separator: " ").compactMap { Int($0) }[1] }!
    let C = readLine().flatMap { $0.split(separator: " ").compactMap { Int($0) } }!
    let D = readLine().flatMap { $0.split(separator: " ").compactMap { Int($0) } }!
    print("Case #\(t): \(countFairFights(K: K, C: C, D: D))")
}
