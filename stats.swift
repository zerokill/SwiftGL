import Foundation
import Accelerate // For efficient mathematical computations (optional)

func calculateMean(_ data: [Double]) -> Double {
    let sum = data.reduce(0, +)
    return sum / Double(data.count)
}

func calculateMedian(_ data: [Double]) -> Double {
    let sortedData = data.sorted()
    let count = data.count
    if count % 2 == 0 {
        return (sortedData[count / 2 - 1] + sortedData[count / 2]) / 2.0
    } else {
        return sortedData[count / 2]
    }
}

func calculateStandardDeviation(_ data: [Double]) -> Double {
    let mean = calculateMean(data)
    let variance = data.reduce(0) { $0 + pow($1 - mean, 2.0) } / Double(data.count)
    return sqrt(variance)
}

