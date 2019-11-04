import Foundation

let maxDoublingTime = 6
let maxQueryResponsePower = 63
let maxElementPower = 7  // 2^MAX_POWER should be strictly greater than any element.

func query(_ q: Int) -> Int64? {
    print(q); fflush(stdout)
    guard let responseLine = readLine(),
          let response = Int64(responseLine) else { return nil }
    return response < 0 ? nil : response
}

func answer<T: Sequence>(_ xs: T) -> Bool where T.Element: LosslessStringConvertible {
    print(xs.map({ String($0) }).joined(separator: " ")); fflush(stdout)
    guard let response = readLine() else { return false }
    return (Int(response) ?? -1)  == 1
}

/// Solves for the smallest integer such that
/// power == floor(x/(divisor - 1)) - floor(x/divisor).
func chooseQuery(divisor: Int, power: Int) -> Int {
    if divisor == 1 { return power }  // If we know everything else, this works.
    var (lower, upper) = (1, Int.max)
    var guess = lower + (upper - lower) / 2
    while (guess / (divisor - 1) - guess / divisor != power ||
             (guess - 1) / (divisor - 1) - (guess - 1) / divisor != power - 1) {
        let test = guess / (divisor - 1) - guess / divisor
        if test >= power { upper = guess } else { lower = guess }
        guess = lower + (upper - lower) / 2
    }
    return guess
}

let args = readLine()!.split(separator: " ").compactMap { Int($0)! }
let (T, _) = (args[0], args[1])
for _ in 0..<T {
    // Initialize state as all zeroes and start from the end.
    var rings: [Int64] = Array(repeating: 0, count: maxDoublingTime + 1)
    var cursor = maxDoublingTime
    while cursor > 0 {  // Assume we have enough guesses.
        let days  = chooseQuery(divisor: cursor, power: maxElementPower)
        if days / cursor >= maxQueryResponsePower {
            fatalError("\(days) days is too large for querying.")
        }
        // Grab response and modify according to information that we already know.
        guard var response = query(days) else { fatalError("Bad response.") }
        for (offset, element) in rings.enumerated().dropFirst(cursor + 1) {
            response -= element << (days / offset)
        }
        // Get all the information available that hasn't been modded out.
        while cursor > 0 && days / cursor < maxQueryResponsePower {
            // Mod out the bigger digits if it hasn't already been done.
            let remainder = cursor > 1 && days / (cursor - 1) < maxQueryResponsePower ?
              response % (1 << (days / (cursor - 1))) : response            
            rings[cursor] = remainder / (1 << (days / cursor))  // Extract the digit.
            response -= remainder  // Update the response.
            cursor -= 1
        }
    }
    assert(answer(rings.dropFirst()), "Solution is not correct.")
}
