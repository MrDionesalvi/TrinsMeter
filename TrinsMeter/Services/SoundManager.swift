import Foundation
import AVFoundation

class SoundManager {
    static let shared = SoundManager()
    private var audioPlayer: AVAudioPlayer?
    
    func playSuccessSound() {
        guard let path = Bundle.main.path(forResource: "trins-2", ofType: "mp3") else {
            print("Suono non trovato")
            return
        }
        
        let url = URL(fileURLWithPath: path)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Errore nella riproduzione del suono: \(error.localizedDescription)")
        }
    }
} 
