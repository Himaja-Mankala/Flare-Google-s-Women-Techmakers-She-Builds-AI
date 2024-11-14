//
//  Gemini Text.swift
//  Flare
//
//  Created by Himaja Mankala on 2024-11-14.
//

import Foundation
import GoogleGenerativeAI

class GeminiText{
    static let geminiText = GeminiText()
    private init() {}
    
    func generateAnalysis(for message: String, completion: @escaping (String?) -> Void){
        let config = GenerationConfig(
            temperature: 1.0,
          topP: 0.95,
          topK: 40,
          maxOutputTokens: 8192,
          responseMIMEType: "text/plain"
        )

        let model = GenerativeModel(
            name:"gemini-1.5-pro-002",
            apiKey: APIKey.default,
            generationConfig: config,
            systemInstruction: "Analyze the following journal entry. Identify any patterns or language that suggests the presence of limiting beliefs, hoplessness, and internalized misogyny. Any interactions that indicate manipulation, gaslighting, abusive language, or control tactics should be highlighted. The language should be analyzed with clear annotation of the implications and draw any academic resources or statistics to support if available. Address areas where the writer may be underestimating themselves, doubting their worth or accepting unhealthy behaviour from others. Teach them how strict boundaries can be placed to remove themselves from unhealthy or potentially dangerous situations. Provide supportive, encouraging and constructive feedback empathetically that encourages self-awareness and empowerment. The goal is to help the writers recognize these patterns, improve their analytical and critical thinking skills, protect themselves from potentially dangerous situations, set boundaries, prioritize self-respect and see opportunites for a better and healthy lifestyle."
        )
        
        Task{
            do {
                let result = try await model.generateContent(message)
                let aiAnalysis = result.text ?? "No Analysis Performed"
                completion(aiAnalysis)
            } catch {
                print("Error: \(error.localizedDescription)")
                completion("Error Generating AI Analysis")
            }
        }
    }
    
    
}
