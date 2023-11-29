//
//  ContentView.swift
//  WordScramble
//
//  Created by Zach Mommaerts on 9/13/23.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var totalWords = 0
    @State private var fourLetterWords = 0
    @State private var fiveLetterWords = 0
    @State private var sixLetterWords = 0
    @State private var sevenLetterWords = 0
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .autocapitalization(.none)
                }
                
                Section("Score") {
                    HStack {
                        VStack {
                            
                        }
                        Text("Total: \(totalWords)")
                        Spacer()
                        Text("4L: \(fourLetterWords)")
                        Spacer()
                        Text("5L: \(fiveLetterWords)")
                        Spacer()
                        Text("6L: \(sixLetterWords)")
                        Spacer()
                        Text("7L: \(sevenLetterWords)")
                    }
                }
                
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack{
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                        .accessibilityElement()
                        .accessibilityLabel(word)
                        .accessibilityHint("\(word.count) letters")
                    }
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
            .navigationBarItems(trailing: Button("New Word", action: startGame))
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 3 else {
            wordError(title: "Word is too short", message: "It's got to be longer than that!")
            return
        }
        
        guard answer != rootWord else {
            wordError(title: "Word is the same", message: "Nice Try!")
            return
        }
        
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
        
        
        withAnimation {
            usedWords.insert(answer, at: 0)
            
            totalWords += 1
            switch answer.count {
            case 4:
                fourLetterWords += 1
            case 5:
                fiveLetterWords += 1
            case 6:
                sixLetterWords += 1
            case 7:
                sevenLetterWords += 1
            default:
                return
            }
        }
        
        newWord = ""
    }
    
    func startGame() {
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                rootWord = allWords.randomElement() ?? "silkworm"
                
                withAnimation{
                    usedWords.removeAll()
                    totalWords = 0
                    fourLetterWords = 0
                    fiveLetterWords = 0
                    sixLetterWords = 0
                    sevenLetterWords = 0
                }
                
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
