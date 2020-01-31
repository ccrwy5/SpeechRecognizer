//
//  SpeechRecognizerViewController.swift
//  SpeechRecognizer
//
//  Created by Chris Rehagen on 1/27/20.
//  Copyright © 2020 Chris Rehagen. All rights reserved.
//

import UIKit
import Speech

class SpeechRecognizerViewController: UIViewController, SFSpeechRecognizerDelegate{

    @IBOutlet weak var convertButton: UIButton!
    @IBOutlet weak var convertedTextLabel: UILabel!
    @IBOutlet weak var clearButton: UIButton!
    
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    let request = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    
    var isRecording = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        convertedTextLabel.text = ""
        convertButton.layer.cornerRadius = 12.0
        clearButton.layer.cornerRadius = 12.0
        convertButton.setTitle("Record", for: .normal)
        convertButton.backgroundColor = UIColor.blue
        clearButton.backgroundColor = UIColor.gray
        

        // Do any additional setup after loading the view.
    }
    
    @IBAction func convertButtonPressed(_ sender: Any) {
        if isRecording == true {
            stopRording()
            isRecording = false
            convertButton.backgroundColor = UIColor.blue
            convertButton.setTitle("Record", for: .normal)
        } else {
            self.recordSpeech()
            isRecording = true
            convertButton.backgroundColor = UIColor.red
            convertButton.setTitle("Stop", for: .normal)
        }
    }
    
    
    @IBAction func clearButtonPressed(_ sender: Any) {
        convertedTextLabel.text = ""
    }
    
    func stopRording() {
        recognitionTask?.finish()
        recognitionTask = nil
        request.endAudio()
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
    }
    
    func recordSpeech(){
        //guard let node = audioEngine.inputNode else { return }
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.request.append(buffer)
        }
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            return print(error)
        }
        
        guard let myRecognizer = SFSpeechRecognizer() else {
            return
        }
        if !myRecognizer.isAvailable{
            return
        }
        recognitionTask = speechRecognizer?.recognitionTask(with: request, resultHandler: { result, error in
            if let result = result {
                
                let bestString = result.bestTranscription.formattedString
                self.convertedTextLabel.text = bestString
            }
        })
    }
    

}

