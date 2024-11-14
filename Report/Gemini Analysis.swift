//
//  Gemini Analysis.swift
//  Flare
//
//  Created by Himaja Mankala on 2024-11-14.
//

import Foundation
import GoogleGenerativeAI

class GeminiAnalysis {
    static let geminiAnalysis = GeminiAnalysis()
    private init() {}
    
    // Function to generate analysis based on latitude and longitude data
    func generateAnalysis(for coordinates: [(latitude: Double, longitude: Double)], completion: @escaping (String?) -> Void) {
        // Convert coordinates to a string that Gemini AI can analyze
        let coordinatesMessage = coordinates.map { "Latitude: \($0.latitude), Longitude: \($0.longitude)" }
                                            .joined(separator: "\n")
        
        // Create the input message for Gemini AI
        let message = """
        Here are the coordinates of the alerts submitted today:
        \(coordinatesMessage)
        
        Please analyze these locations and provide insights related to any patterns, geographical trends, or anything that stands out.
        Any relevant details about distances, high risk clusters, frenquencys of alerts from same locations, or patterns should be highlighted. Also, check for unusual patterns based on the locations and perform a risk analysis.
        """
        print("Sending the following message to Gemini AI:\n\(message)")
        
        // Configuration for the model
        let config = GenerationConfig(
            temperature: 1.0,
            topP: 0.95,
            topK: 40,
            maxOutputTokens: 8192,
            responseMIMEType: "text/plain"
        )

        // Initialize the generative model
        let model = GenerativeModel(
            name: "gemini-1.5-pro-002",
            apiKey: APIKey.default,
            generationConfig: config,
            systemInstruction: "Analyze the following geographical data and provide relevant insights, trends, or patterns based on the following alert location. Cater it towards women's safety. The goal is to be protected and minimize exposure to high risk areas"
        )
        
        // Run the analysis task
        Task {
            do {
                print("Sending request to Gemini AI...")
                let result = try await model.generateContent(message)
                print("Gemini AI response received.")
                let aiAnalysis = result.text ?? "No Analysis Performed"
                completion(aiAnalysis)
            } catch {
                print("Error: \(error.localizedDescription)")
                print("Error: \(error.localizedDescription)")
                completion("Error Generating AI Analysis")
            }
        }
    }
}
