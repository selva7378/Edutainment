//
//  ContentView.swift
//  Edutainment
//
//  Created by Remitbee on 08/11/26.
//

import SwiftUI

// A simple struct to hold each question and its correct answer
struct Question {
    let text: String
    let answer: Int
}

struct ContentView: View {
    // Game configuration settings
    @State private var upToTable = 5
    @State private var selectedQuestionCount = 10
    let questionOptions = [5, 10, 20]
    
    // Game state tracking
    @State private var isGameActive = false
    @State private var questions: [Question] = []
    @State private var currentQuestionIndex = 0
    @State private var userAnswer = ""
    @State private var score = 0
    
    // Feedback Alerts
    @State private var showingFeedbackAlert = false
    @State private var feedbackTitle = ""
    @State private var feedbackMessage = ""
    @State private var isGameOver = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Playful background gradient
                LinearGradient(
                    colors: [Color.indigo.opacity(0.8), Color.mint.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    if !isGameActive {
                        // MARK: - SETTINGS VIEW
                        settingsCard
                    } else {
                        // MARK: - ACTIVE GAMEPLAY VIEW
                        gameplayCard
                    }
                }
                .padding()
            }
            .navigationTitle("Edutainment 🎮")
            .navigationBarTitleDisplayMode(.inline)
            // Alert after each answer
            .alert(feedbackTitle, isPresented: $showingFeedbackAlert) {
                Button("Next", action: advanceToNextQuestion)
            } message: {
                Text(feedbackMessage)
            }
            // Alert when game completes
            .alert("Game Over! 🏆", isPresented: $isGameOver) {
                Button("Play Again", action: resetGame)
            } message: {
                Text("Great job! You scored \(score) out of \(questions.count).")
            }
        }
    }
    
    // MARK: - Settings Subview
    private var settingsCard: some View {
        VStack(spacing: 20) {
            Text("Multiplication Practice")
                .font(.title2.bold())
                .foregroundStyle(.primary)
            
            // 1. Practice tables up to...
            VStack(alignment: .leading, spacing: 8) {
                Text("Practice tables up to: **\(upToTable)**")
                    .font(.headline)
                
                Stepper("Table up to \(upToTable)", value: $upToTable, in: 2...12)
                    .labelsHidden()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(.thinMaterial)
            .clipShape(.rect(cornerRadius: 15))
            
            // 2. Number of questions picker
            VStack(alignment: .leading, spacing: 8) {
                Text("How many questions?")
                    .font(.headline)
                
                Picker("Questions", selection: $selectedQuestionCount) {
                    ForEach(questionOptions, id: \.self) { count in
                        Text("\(count)")
                    }
                }
                .pickerStyle(.segmented)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(.thinMaterial)
            .clipShape(.rect(cornerRadius: 15))
            
            // 3. Start Game button
            Button {
                withAnimation(.spring(duration: 0.5)) {
                    startGame()
                }
            } label: {
                Label("Start Game", systemImage: "play.circle.fill")
                    .font(.title3.bold())
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(.capsule)
                    .shadow(radius: 5)
            }
            .padding(.top, 10)
        }
        .padding(25)
        .background(.regularMaterial)
        .clipShape(.rect(cornerRadius: 24))
        .shadow(radius: 10)
    }
    
    // MARK: - Gameplay Subview
    private var gameplayCard: some View {
        VStack(spacing: 20) {
            // Header: Progress & Score
            HStack {
                Text("Question \(currentQuestionIndex + 1) of \(questions.count)")
                    .font(.subheadline.bold())
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text("Score: \(score)")
                    .font(.headline.bold())
                    .foregroundStyle(.blue)
            }
            
            // The Question prompt
            if !questions.isEmpty && currentQuestionIndex < questions.count {
                Text(questions[currentQuestionIndex].text)
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .padding(.vertical, 15)
                
                // Kid's Answer input
                TextField("Enter answer", text: $userAnswer)
                    .keyboardType(.numberPad)
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(.rect(cornerRadius: 15))
                    .padding(.horizontal, 20)
                
                // Submit Button
                Button(action: checkAnswer) {
                    Text("Submit Answer")
                        .font(.title3.bold())
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(userAnswer.isEmpty ? Color.gray : Color.green)
                        .foregroundStyle(.white)
                        .clipShape(.capsule)
                        .shadow(radius: 4)
                }
                .disabled(userAnswer.isEmpty)
                
                // End game early button
                Button("Quit Game") {
                    withAnimation {
                        resetGame()
                    }
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.top, 8)
            }
        }
        .padding(25)
        .background(.regularMaterial)
        .clipShape(.rect(cornerRadius: 24))
        .shadow(radius: 10)
    }
    
    // MARK: - Game Logic
    
    func startGame() {
        questions.removeAll()
        
        // Generate a pool of all valid multiplications up to upToTable
        var allPossibleQuestions: [Question] = []
        for table in 2...upToTable {
            for multiplier in 1...12 {
                let text = "What is \(table) × \(multiplier)?"
                let answer = table * multiplier
                allPossibleQuestions.append(Question(text: text, answer: answer))
            }
        }
        
        // Shuffle and take the requested number of questions
        allPossibleQuestions.shuffle()
        questions = Array(allPossibleQuestions.prefix(selectedQuestionCount))
        
        // Reset counters
        currentQuestionIndex = 0
        score = 0
        userAnswer = ""
        isGameActive = true
    }
    
    func checkAnswer() {
        guard let answerInt = Int(userAnswer) else { return }
        
        let currentQuestion = questions[currentQuestionIndex]
        if answerInt == currentQuestion.answer {
            score += 1
            feedbackTitle = "Correct! 🎉"
            feedbackMessage = "Awesome job, that's right!"
        } else {
            feedbackTitle = "Oops! ❌"
            feedbackMessage = "The correct answer was \(currentQuestion.answer)."
        }
        
        showingFeedbackAlert = true
    }
    
    func advanceToNextQuestion() {
        userAnswer = ""
        
        if currentQuestionIndex + 1 < questions.count {
            currentQuestionIndex += 1
        } else {
            isGameOver = true
        }
    }
    
    func resetGame() {
        isGameActive = false
        questions.removeAll()
        currentQuestionIndex = 0
        score = 0
        userAnswer = ""
    }
}

#Preview {
    ContentView()
}
