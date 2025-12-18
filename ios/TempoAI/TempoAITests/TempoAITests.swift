import Testing

@testable import TempoAI

struct TempoAITests {

    @Test("TempoAI app initializes without crashing")
    func appInitialization() {
        #expect(TempoAIApp() != nil)
    }

    @Test("ContentView can be created successfully")
    func contentViewCreation() {
        let contentView = ContentView()
        #expect(contentView != nil)
    }
}
