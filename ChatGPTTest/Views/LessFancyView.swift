//
//  ContentView.swift
//  ChatGPTTest
//
//  Created by Russell Gordon on 2024-06-12.
//

import OpenAI
import SwiftUI

struct LessFancyView: View {
    
    // MARK: Stored properties
    @State private var response: String? = nil

    // MARK: Computed properties
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Button {
                        Task {
                            response = try await getBookRecommendations()
                        }
                    } label: {
                        Text("Get Book Recommendations")
                    }
                    .buttonStyle(.borderedProminent)

                    // Only show the text view when there is a response...
                    if let response = response {
                        Text(response)
                            .monospaced()
                    }
                }
                .padding()
            }
            .navigationTitle("Less Fancy Test")
        }
    }
    
    // MARK: Functions
    private func getBookRecommendations() async throws -> String? {

        // NOTE: See Mr. Gordon to obtain your API key.
        //
        //       Add a file named Secrets.swift to a Helpers group in your project.
        //       The file must be named exactly as shown.
        //       Define a constant named like this that includes the apiKey you were provided with:
        //
        //       let apiKey = "REPLACE_WITH_YOUR_API_KEY"
        //
        let openAI = OpenAI(apiToken: apiKey)
        
        // Define the question
        let question = """
                    I've read these three books recently and really enjoyed them.

                    I am providing the information to you in JSON format, with two name-value pairs describing the name and author of each book.

                    Using the same JSON structure, please give me a recommendation for three new books to read.

                    [
                    {
                        id: 1,
                        name: "Outlander",
                        author: "Diana Gabaldon"
                    },
                    {
                        id: 2,
                        name: "The Mountain in the Sea"
                        author: "Ray Nayler"
                    },
                    {
                        id: 3,
                        name: "Dark Matter",
                        author: "Blake Crouch"
                    }
                    ]

                    Please include only the JSON structure in your response, with no other text before or after your reply.
                    """
        
        // Build the query
        let query = ChatQuery(
            messages: [ChatQuery.ChatCompletionMessageParam(
                role: .user,
                content: question
            )!],
            model: .gpt4_o
        )

        do {
            // Execute the query
            let result = try await openAI.chats(query: query)
            
            // Once query is received, return the response
            return result.choices.first?.message.content?.string ?? nil
        } catch {
            debugPrint(error)
        }
        
        // Shouldn't ever get here, but a return statement to satisfy the Swift compiler
        return nil

    }
}

#Preview {
    LandingView(selectedTab: Binding.constant(1))
}
