import Foundation
import HealthKit
import XCTest

@testable import TempoAI

class MockHealthKitQueryFactory: HealthKitQueryFactory {
    var capturedResultsHandlers: [(HKSampleQuery, [HKSample]?, Error?) -> Void] = []
    var capturedQueries: [HKSampleQuery] = []

    func createSampleQuery(
        sampleType: HKSampleType,
        predicate: NSPredicate?,
        limit: Int,
        sortDescriptors: [NSSortDescriptor]?,
        resultsHandler: @escaping (HKSampleQuery, [HKSample]?, Error?) -> Void
    ) -> HKSampleQuery {
        let query = HKSampleQuery(
            sampleType: sampleType,
            predicate: predicate,
            limit: limit,
            sortDescriptors: sortDescriptors
        ) { _, _, _ in
            // Empty handler - we'll use capturedResultsHandlers instead
        }

        capturedQueries.append(query)
        capturedResultsHandlers.append(resultsHandler)

        return query
    }

    func triggerHandler(at index: Int, with samples: [HKSample]?, error: Error? = nil) {
        guard index < capturedResultsHandlers.count && index < capturedQueries.count else { return }
        let handler = capturedResultsHandlers[index]
        let query = capturedQueries[index]
        handler(query, samples, error)
    }
}
