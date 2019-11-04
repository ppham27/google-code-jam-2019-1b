#include <algorithm>
#include <functional>
#include <iostream>
#include <utility>
#include <vector>

using namespace std;

int MostSignificantBit(int x) {
  return 8 * sizeof(int) - __builtin_clz(x);
}

// Chooses the left-most sword with the most skill.
pair<int, int> Reduce(const pair<int, int>& a, const pair<int, int>& b) {
  if (a.first > b.first) return a;
  if (b.first > a.first) return b;  
  return a.second <= b.second ? a : b;
}

// Creates a table `memo` such that memo[i][j] is the maximum sword over the
// the interval values[i],...,values[i + 2^j - 1].
vector<vector<pair<int, int>>> Memoize(const vector<pair<int, int>>& values) {
  const int N = values.size();
  const int most_significant_bit = MostSignificantBit(N);
  vector<vector<pair<int, int>>> memo; memo.reserve(N);
  for (const pair<int, int>& value : values) {
    memo.emplace_back();
    memo.back().reserve(most_significant_bit);
    memo.back().push_back(value);
  } 
  for (int j = 1; j < most_significant_bit; ++j) {
    int offset = 1 << (j - 1);
    for (int i = 0; i < N; ++i) {
      memo[i].push_back(i + offset < N ?
                        Reduce(memo[i][j - 1], memo[i + offset][j - 1]) : memo[i][j - 1]);
    }
  }
  return memo;
}

// Uses the table created by `Memoize` to perform constant-time range queries.
pair<int, int> QueryMax(const vector<vector<pair<int, int>>> &memo,
                        int from, int to) {
  int range = to - from;
  int bit_shift = MostSignificantBit(range) - 1;
  int offset = 1 << bit_shift;
  return Reduce(memo[from][bit_shift], memo[to - offset][bit_shift]);
}

// Finds the first value `x` in the range `[from, to)` such that `test(x)` is
// true. If no such `x` exists, returns `to`.
int Search(int from, int to, const function<bool(int)>& test) {
  if (from == to) return from;
  const int x = from + (to - from) / 2;
  return test(x) ? Search(from, x, test) : Search(x + 1, to, test);
}

// Counts the the number of fair fights over a specified range.
long long CountFairFights(int K,
                          const vector<vector<pair<int, int>>>& C,
                          const vector<vector<pair<int, int>>>& D,
                          int from, int to) {
  if (from >= to) return 0;
  // Find all fair fights that contain the pivot.
  pair<int, int> pivot = QueryMax(C, from, to);
  // Intervals that contain the pivot with an opposing max at most K more.
  long long L = Search(from, pivot.second + 1,
                       [&](int x) {
                         return QueryMax(D, x, pivot.second + 1).first <= pivot.first + K;
                       });
  long long R = Search(pivot.second, to,
                       [&](int x) {  // Negate to find exclusive upper bound.
                         return QueryMax(D, pivot.second, x + 1).first > pivot.first + K;
                       });
  // Intervals that contain the pivot with an opposing max that is too small.
  long long l = Search(L, pivot.second + 1,
                       [&](int x) {
                         return QueryMax(D, x, pivot.second + 1).first < pivot.first - K;
                       });
  long long r = Search(pivot.second, R,
                       [&](int x) {  // Negate to find exclusive upper bound.
                         return QueryMax(D, pivot.second, x + 1).first >= pivot.first - K;
                       });
  return (pivot.second - L + 1) * (R - pivot.second) -
    (pivot.second - l + 1) * (r - pivot.second) +
    CountFairFights(K, C, D, from, pivot.second) +
    CountFairFights(K, C, D, pivot.second + 1, to);
}

// Counts the number of fair fights.
long long CountFairFights(int K,
                          const vector<pair<int, int>>& C,
                          const vector<pair<int, int>>& D) {
  return CountFairFights(K, Memoize(C), Memoize(D), 0, max(C.size(), D.size()));
}

int main(int argc, char *argv[]) {
  ios::sync_with_stdio(false); cin.tie(NULL);
  int T; cin >> T;
  for (int t = 0; t < T; ++t) {
    int N, K; cin >> N >> K;
    vector<pair<int, int>> C, D; C.reserve(N); D.reserve(N);
    for (int i = 0; i < N; ++i) {
      int c; cin >> c; C.emplace_back(c, i);
    }
    for (int i = 0; i < N; ++i) {
      int d; cin >> d; D.emplace_back(d, i);
    }
    cout << "Case #" << (t + 1) << ": "
         << CountFairFights(K, C, D) << '\n';
  }
  cout << flush;
  return 0;
}
