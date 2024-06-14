//
//  FancyView.swift
//  ChatGPTTest
//
//  Created by Russell Gordon on 2024-06-13.
//

import OpenAI
import SwiftUI

// MODEL
struct Book: Identifiable, Codable {
    let id: Int
    let name: String
    let author: String
}

let exampleBooks = [
    Book(id: 1, name: "Outlander", author: "Diana Gabaldon"),
    Book(id: 2, name: "The Mountain in the Sea", author: "Ray Nayler"),
]

// VIEW
struct FancyView: View {
    
    // MARK: Stored properties
    
    // Keeps track of the books the user already likes
    @State private var booksAlreadyRead: [Book] = exampleBooks
    
    // Keeps track of the book a user is entering
    @State private var newBookName = ""
    @State private var newBookAuthor = ""
    
    // The response from ChatGPT
    @State private var response: String? = nil
    @State private var bookSuggestions: [Book] = []
        
    // MARK: Computed properties
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {

                    // Controls to add a book the user has liked
                    Group {
                        Text("What are a few books you've read and liked?")
                            .font(.title3)
                            .bold()
                        TextField("Name of book", text: $newBookName)
                            .textFieldStyle(.roundedBorder)
                        TextField("Author of book", text: $newBookAuthor)
                            .textFieldStyle(.roundedBorder)

                        Button {
                            // Add the book to the list of books the user likes
                            let newBook = Book(
                                id: booksAlreadyRead.count + 1,
                                name: newBookName,
                                author: newBookAuthor
                            )
                            // Add to top of list
                            booksAlreadyRead.insert(newBook, at: 0)
                        } label: {
                            Text("Add")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    
                    // Show the books the user has entered
                    List(booksAlreadyRead) { book in
                        VStack(alignment: .leading) {
                            Text(book.name)
                                .bold()
                            Text(book.author)
                                .font(.subheadline)
                        }
                    }
                    .listStyle(.plain)
                    .frame(height: 200)
                                    
                    // Allow user to ask for book recommendations
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
                        
                        Group {
                            Text("Here are some new books you might enjoy...")
                                .font(.title3)
                                .bold()
                            
                            // Show the book recommendations
                            List(bookSuggestions) { book in
                                VStack(alignment: .leading) {
                                    Text(book.name)
                                        .bold()
                                    Text(book.author)
                                        .font(.subheadline)
                                }
                            }
                            .listStyle(.plain)
                            .frame(height: 200)

                        }
                    }
                    
                    Spacer()

                }
                .padding()
            }
            .navigationTitle("Fancy Test")
        }
        .onChange(of: response) {
            // When there is a non-nil response from ChatGPT, decode it into an array of suggestions
            // NOTE: This is a good reference for tips on encoding and decoding JSON
            //       https://www.swiftyplace.com/blog/codable-how-to-simplify-converting-json-data-to-swift-objects-and-vice-versa
            if let response = response {
                
                let decoder = JSONDecoder()
                do {

                    // Turn the string into an instanc of the Data type (required to decode from JSON)
                    let data = Data(response.utf8)
                    
                    // Try to decode ChatGPT's response into an array of book suggestions
                    bookSuggestions = try decoder.decode([Book].self, from: data)
                    
                } catch {
                    debugPrint(error)
                }
                
            }
        }
    }
    
    // MARK: Functions
    private func getBookRecommendations() async throws -> String? {
        
        // Encode the list of books to JSON
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        var booksListInJSON = ""
        do {
            let jsonData = try encoder.encode(booksAlreadyRead)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                
                // DEBUG
                print("Books the user has read, encoded in JSON, are:")
                print("")
                print(jsonString)
                
                
                // Assign the encoded JSON to a variable we'll use later to build the question
                booksListInJSON = jsonString
            }
        } catch {
            debugPrint(error)
            return nil
        }
        
        // NOTE: See Mr. Gordon to obtain your API key.
        //
        //       Add a file named Secrets.swift to a Helpers group in your project.
        //       The file must be named exactly as shown.
        //       Define a constant named like this that includes the apiKey you were provided with:
        //
        //       let apiKey = "REPLACE_WITH_YOUR_API_KEY"
        //
        let openAI = OpenAI(apiToken: apiKey)
                
        // Define the question preamble
        let questionPreamble = """
                    I've read these books recently and really enjoyed them.

                    I am providing the information to you in JSON format, with two name-value pairs describing the name and author of each book.

                    Using the same JSON structure, please give me a recommendation for three new books to read.
                    
                    
                    """
        
        // Define the question conclusion
        let questionConclusion = """
                    
                    
                    Please include only the JSON structure in your response, with no other text before or after your reply.
                    """
        
        // Assemble the entire question
        let question = questionPreamble + booksListInJSON + questionConclusion
        // DEBUG
        print("======")
        print(question)
        
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
            
            // DEBUG: What was the response?
            print("=====")
            print("Result from ChatGPT was...")
            print("")
            print(result)
            
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
    LandingView(selectedTab: Binding.constant(2))
}
