//
//  ContentView.swift
//  WordScramble
//
//  Created by Work Experience on 03/03/2026.
//
import SwiftUI

struct ContentView: View {
    
    @FocusState private var isFieldFocused: Bool
    
    @State private var score = 0
    @State private var highScore = 0
    
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
                
        NavigationStack {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                    .focused($isFieldFocused)
                        .onSubmit {
                            // Keep the keyboard up by setting focus back to true
                            isFieldFocused = true
                        }
                    .textInputAutocapitalization(.never)
                    .onAppear {
                        isFieldFocused = true
                    }
                }

                Section {
                    ForEach(usedWords, id: \.self) { word in
                        ZStack {
                            
                            if word.count == 3 {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.yellow)
                            }
                            
                            if word.count == 4 {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.yellow)
                            }
                            
                            if word.count == 5 {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.green)
                            }
                            
                            if word.count == 6 {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.blue)
                            }
                            
                            if word.count == 7 {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.purple)
                            }
                            
                            if word.count == 8 {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.purple)
                            }
                            
                            
                            
                            
                            HStack {
                                Image(systemName: "\(word.count).circle")
                                Text(word)
            
                            }
                        }
                    }
                }
            }
            .toolbar {
                Button("Restart", systemImage: "arrow.clockwise") {
                    startGame()
                }
            }
            .toolbar {
                Text("Score: \(score)")
            }
            
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                        Text("High score: \(highScore)")
                }
            }
            
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        guard answer.count > 0 else { return }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original!")
            return
        }

        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }

        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        guard isLong(word: answer) else {
            wordError(title: "Word too short", message: "Stop being so basic!")
            return
        }
        
        guard isRoot(word: answer) else {
            wordError(title: "Word already given", message: "Don't try to cheat the system!")
            return
        }
        
        scoreAdd(word: answer)
        highScoreAdd(word: answer)

        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        newWord = ""
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL, encoding:.utf8) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                score = 0
                usedWords.removeAll()
                
                return
            }
        }
        fatalError("Could not load start.txt from bundle.")
    }
        
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord

        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }

        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    func isLong(word: String) -> Bool{
        word.count >= 3
    }
    
    func isRoot(word: String) -> Bool{
        rootWord != word
    }
    
    func scoreAdd(word: String) {
        self.score += word.count

    }
    
    func highScoreAdd(word: String) {
        if score >= highScore {
            highScore = score
        }
    }
}

#Preview {
    ContentView()
}
