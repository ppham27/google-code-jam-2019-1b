/// Finds the index that has the most weight directed at it.
func concentrate(forward: inout [Int], reverse: inout [Int]) -> Int {
    assert(forward.count == reverse.count,
           "forward and reverse must be the same size")
    let count = forward.count
    for i in 1..<count {
        // Count from left to right.
        forward[i] += forward[i - 1]
        // Count from right to left.
        reverse[count - 1 - i] += reverse[count - i]
    }
    var counts = Array(repeating: 0, count: count)
    if count > 1 {  // Initialize boundary case.
        counts[0] += reverse[1]
        counts[count - 1] += forward[count - 2]
    }
    for i in 1..<(count - 1) {
        counts[i] += forward[i - 1] + reverse[i + 1]
    }    
    return counts.enumerated().max(
      by: {
          $0.element != $1.element ? $0.element < $1.element : $0.offset > $1.offset    
      })!.offset
}

enum Direction: Character {
    case north = "N"
    case south = "S"
    case east = "E"
    case west = "W"
}

guard let args = readLine(), let T = Int(args) else {
    fatalError("Missing number of test cases.")
}
for t in 1...T {
    let params = readLine()!.split(separator: " ").compactMap { Int($0) }
    let (P, Q) = (params[0],  params[1])
    // Count of people going each direction at each point.
    var north = Array(repeating: 0, count: Q + 1)
    var south = Array(repeating: 0, count: Q + 1)
    var east = Array(repeating: 0, count: Q + 1)
    var west = Array(repeating: 0, count: Q + 1)
    for _ in 0..<P {
        guard let pointLine = readLine() else { fatalError("Missing point.") }
        let pointParams = pointLine.split(separator: " ")
        guard let character = pointParams[2].first,
              let direction = Direction(rawValue: character) else {
            fatalError("Missing or invalid direction in \(pointParams).")
        }
        switch direction {
        case Direction.north: north[Int(pointParams[1])!] += 1
        case Direction.south: south[Int(pointParams[1])!] += 1
        case Direction.east: east[Int(pointParams[0])!] += 1
        case Direction.west: west[Int(pointParams[0])!] += 1
        }
    }
    let (x, y) = (concentrate(forward: &east, reverse: &west),
                  concentrate(forward: &north, reverse: &south))
    print("Case #\(t): \(x) \(y)")
}
