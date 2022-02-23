//
//  ContentView.swift
//  MICHAELMCGINNIS-WordScramble
//
//  Created by Michael Mcginnis on 2/16/22.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    @State private var playerScore = 0
    
    func addNewWord(){
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard answer.count > 0 else {return}
        
        guard isShort(word: answer)else{
            wordError(title: "Word too short!", message: "Word needs to be longer than 2 characters")
            return
        }
        guard isStart(word: answer)else{
            wordError(title: "Word is the same as start word!", message: "Be a little more creative than that..")
            return
        }
        guard isOriginal(word: answer)else{
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        
        guard isPossible(word: answer)else{
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }
        guard isReal(word: answer)else{
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        playerScore += answer.count
        withAnimation{
            usedWords.insert(answer, at: 0)
        }
        newWord = ""
    }
    
    func startGame(){
        playerScore = 0
        usedWords.removeAll()
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt"){
            if let startWords = try? String(contentsOf: startWordsURL){
                let allWords = startWords.components(separatedBy: "\n")
                
                rootWord = allWords.randomElement() ?? "silkworm"
                
                return
            }
        }
        fatalError("Could not load start.txt from the bundle.")
    }
    
    func isShort(word: String) -> Bool{
        if word.count < 3{
            return false
        }
        return true
    }
    func isStart(word: String) -> Bool{
        if word == rootWord{
            return false
        }
        return true
    }
    
    func isOriginal(word: String) -> Bool{
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool{
        var tempWord = rootWord
        for letter in word{
            if let pos = tempWord.firstIndex(of: letter){
                tempWord.remove(at: pos)
            }else{
                return false
            }
        }
        
        return true
    }
    
    func isReal(word: String) -> Bool{
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    //error handling
    func wordError(title: String, message: String){
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    var body: some View {
        NavigationView{
            VStack{
                List{
                    Section{
                        TextField("Enter your word", text: $newWord)
                            .textInputAutocapitalization(.none)
                    }
                    Section{
                        ForEach(usedWords, id: \.self){ word in
                            HStack{
                                Image(systemName: "\(word.count).circle")
                                Text(word)
                            }
                        }
                    }
                }.listStyle(InsetGroupedListStyle())
                /*
                 https://stackoverflow.com/questions/64350979/make-list-sections-non-collapsible-in-swiftui-when-embedded-into-a-navigationvie/64351552#64351552?newreg=ef0f624667b946ef9048d8a0bc961b61
                 */
                Text("Score: \(playerScore)").font(.largeTitle)
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .toolbar{
                Button("Reset Game", action: startGame)
            }
            .alert(errorTitle, isPresented: $showingError){
                Button("OK", role: .cancel){}
            } message: {
                Text(errorMessage)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
.previewInterfaceOrientation(.portrait)
    }
}
