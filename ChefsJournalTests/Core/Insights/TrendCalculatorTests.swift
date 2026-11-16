import Testing
@testable import ChefsJournal

struct TrendCalculatorTests {
    @Test(arguments: [
        ([8, 9, 7, 8, 7, 8], Trend?.some(.steady)),
        ([9, 8, 6, 5], .some(.slipping)),
        ([5, 6, 8, 9], .some(.improving)),
        ([7, 7], nil),
        ([], nil),
        ([9, 1, 5], .some(.slipping)),
        ([7, 8, 7, 7], .some(.steady)),
        ([7, 7, 7, 8], .some(.steady)),
        ([6, 7, 8, 8], .some(.improving)),
    ])
    func trend(scores: [Int], expected: Trend?) {
        #expect(TrendCalculator.trend(for: scores) == expected)
    }
}
