import Foundation

final class MockAIService {
    private let fixtures: [AnalyzePhotoResponse]

    init() {
        if let url = Bundle.main.url(forResource: "mock_diagnosis", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let fixtures = try? JSONDecoder().decode([AnalyzePhotoResponse].self, from: data) {
            self.fixtures = fixtures
        } else {
            self.fixtures = []
        }
    }

    func randomFixture() -> AnalyzePhotoResponse? {
        if let fixture = fixtures.randomElement() {
            return fixture
        }
        return AnalyzePhotoResponse(
            issueTitle: "Loose hinge causing door sag",
            confidence: 72,
            difficulty: "Easy",
            estimatedMinutes: 30,
            highLevelOverview: [
                "Inspect hinge screws and mounting plate",
                "Tighten or replace stripped screws",
                "Realign the door and test movement"
            ],
            tools: [
                ToolItem(name: "Phillips screwdriver", quantity: 1, mustHave: true),
                ToolItem(name: "Drill", quantity: 1, mustHave: false)
            ],
            parts: [
                PartItem(name: "Cabinet hinge", variants: ["Overlay", "Inset"], notes: "Match the current hinge style.")
            ],
            steps: [
                RepairStep(order: 1, title: "Inspect hinge", detail: "Check the hinge screws and plate."),
                RepairStep(order: 2, title: "Tighten screws", detail: "Tighten all hinge screws evenly."),
                RepairStep(order: 3, title: "Replace if needed", detail: "Swap stripped screws or the hinge."),
                RepairStep(order: 4, title: "Align door", detail: "Adjust hinge screws to align the door.")
            ],
            safetyChecklist: ["Keep fingers away from hinge pinch points."],
            commonMistakes: ["Over-tightening screws and stripping holes."],
            verifyBeforeBuy: ["Confirm hinge overlay and cup size."]
        )
    }
}
