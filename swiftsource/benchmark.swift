import Foundation
import Accelerate // For efficient mathematical computations (optional)

import PrimeModule

func isPrime(_ n: Int) -> Bool {
    if n <= 1 { return false }
    if n <= 3 { return true }
    if n % 2 == 0 || n % 3 == 0 { return false }
    var i = 5
    while i * i <= n {
        if n % i == 0 || n % (i + 2) == 0 {
            return false
        }
        i += 6
    }
    return true
}

func runBenchmark(limit: Int) -> TimeInterval {
    let start = CFAbsoluteTimeGetCurrent()

    var sum: Int64 = 0
    for i in 2...limit {
        if isPrime(i) {
            sum += Int64(i)
        }
    }

    let end = CFAbsoluteTimeGetCurrent()
    let timeSpent = end - start

    // Uncomment to verify correctness
    // print("Sum of primes up to \(limit): \(sum)")

    return timeSpent
}

func benchmark() {
    var executionTimes = [Double]()
    let ITERATIONS = 100
    let LIMIT = 100000

    for _ in 1...ITERATIONS {
        let timeSpent = isPrimeBenchmark(Int32(LIMIT))
        executionTimes.append(timeSpent)
    }

    // Perform statistical analysis
    let meanTime = calculateMean(executionTimes)
    let medianTime = calculateMedian(executionTimes)
    let stdDevTime = calculateStandardDeviation(executionTimes)

    // Display results
    print("\nStatistical Analysis over \(ITERATIONS) iterations:")
    print(String(format: "Mean execution time: %.6f seconds", meanTime))
    print(String(format: "Median execution time: %.6f seconds", medianTime))
    print(String(format: "Standard deviation: %.6f seconds", stdDevTime))

    for _ in 1...ITERATIONS {
        let timeSpent = runBenchmark(limit: LIMIT)
        executionTimes.append(timeSpent)
    }

    // Perform statistical analysis
    let meanTimeSwift = calculateMean(executionTimes)
    let medianTimeSwift = calculateMedian(executionTimes)
    let stdDevTimeSwift = calculateStandardDeviation(executionTimes)

    // Display results
    print("\nStatistical Analysis over \(ITERATIONS) iterations:")
    print(String(format: "Mean execution time: %.6f seconds", meanTimeSwift))
    print(String(format: "Median execution time: %.6f seconds", medianTimeSwift))
    print(String(format: "Standard deviation: %.6f seconds", stdDevTimeSwift))
}
