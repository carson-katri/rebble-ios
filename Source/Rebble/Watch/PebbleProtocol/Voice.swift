//
//  Voice.swift
//  Dictation support
//
//  Created by Carson Katri on 2/2/18.
//  Copyright © 2018 Carson Katri. All rights reserved.
//

import Foundation

enum SetupResult: Int {
    case success = 0
    case failTimeout = 2
    case failDisabled = 5
}

enum TranscriptionResult: Int {
    case success = 0
    case failNoInternet = 1
    case failRecognizerError = 3
    case failSpeechNotRecognized = 4
}

/* Dictation */
class Voice {
    var pebble: Pebble!
    var sessionId = 0
    
    init(pebble: Pebble, sessionId: Int) {
        self.pebble = pebble
        self.sessionId = sessionId
        
        self.pebble.registerEndpoint(Endpoint.ENDPOINT_VOICECONTROL, callback: self.voiceControl())
        self.pebble.registerEndpoint(Endpoint.ENDPOINT_AUDIOSTREAM, callback: self.audioStream())
    }
    
    func voiceControl() {
        
    }
    
    func audioStream() {
        
    }
}
