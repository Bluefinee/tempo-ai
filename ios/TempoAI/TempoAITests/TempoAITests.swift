import Testing

@testable import TempoAI

struct TempoAITests {

    @Test("TempoAI app initializes without crashing")
    func appInitialization() {
        // Verifies app can be instantiated without crashing
        let app = TempoAIApp()
        #expect(type(of: app) == TempoAIApp.self)
    }

    @Test("ContentView can be created successfully")
    func contentViewCreation() {
        let contentView = ContentView()
        #expect(type(of: contentView) == ContentView.self)
    }
}
