import Foundation
import AVFoundation
import UIKit

class FireSoundManager: ObservableObject {
    private var audioEngine: AVAudioEngine?
    private var noiseNode: AVAudioSourceNode?
    private var eqNode: AVAudioUnitEQ?
    private var reverbNode: AVAudioUnitReverb?
    
    @Published private var isPlaying = false
    private var masterVolume: Float = 0.5
    private let audioQueue = DispatchQueue(label: "com.burnitaway.audio", qos: .userInitiated)
    
    // Soundscape selection
    enum Profile { case fire }
    private var profile: Profile = .fire
    
    // State for procedural synthesis
    private var sampleRate: Double = 44100
    private var lfo1Phase: Double = 0
    private var lfo2Phase: Double = 0
    private var lfo3Phase: Double = 0
    private var tonePhase: Double = 0
    private let lfo1Freq: Double = 0.15  // Slower, more meditative
    private let lfo2Freq: Double = 0.25  // Gentle breathing rhythm
    private let lfo3Freq: Double = 0.08  // Very slow, deep rhythm
    private let toneFreq: Double = 55.0  // Low, soothing fundamental tone
    
    // Pink noise filter state (Paul Kellet method)
    private var b0: Float = 0
    private var b1: Float = 0
    private var b2: Float = 0
    
    // Crackle burst state (fire)
    private var crackleBurstFramesRemaining: Int = 0
    private var crackleBurstAmplitude: Float = 0
    private var crackleTimer: Timer?
    

    
    // Fade-in envelope
    private var initialFadeInSamples: Int = 0
    private var fadeInSamplesRemaining: Int = 0
    
    init() {
        setupAudioSession()
    }
    
    func setSoundscape(_ soundscape: String) {
        // Only fire soundscape is supported
        profile = .fire
        if isPlaying {
            // Use async to prevent threading issues
            DispatchQueue.main.async { [weak self] in
                self?.stopFireSounds()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self?.startFireSounds()
                }
            }
        }
    }
    
    func setMasterVolume(_ volume: Float) {
        masterVolume = max(0.0, min(1.0, volume))
        // Ensure volume changes are thread-safe
        DispatchQueue.main.async { [weak self] in
            self?.audioEngine?.mainMixerNode.outputVolume = self?.masterVolume ?? 0.5
        }
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    func startFireSounds() {
        guard !isPlaying else { return }
        
        // Ensure we're on the main thread for state changes
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.isPlaying = true
            self.startEngine()
            self.scheduleCrackles()
        }
    }
    
    func stopFireSounds() {
        // Ensure we're on the main thread for cleanup
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.isPlaying = false
            self.crackleTimer?.invalidate()
            self.crackleTimer = nil
            
            // Stop and cleanup audio engine safely
            self.audioEngine?.stop()
            self.audioEngine?.reset()
            self.audioEngine = nil
            self.noiseNode = nil
            self.eqNode = nil
            self.reverbNode = nil
        }
    }
    
    private func startEngine() {
        // Ensure audio engine setup is thread-safe
        audioQueue.async { [weak self] in
            guard let self = self else { return }
            
            let engine = AVAudioEngine()
            let mainMixer = engine.mainMixerNode
            let hwFormat = mainMixer.outputFormat(forBus: 0)
            self.sampleRate = hwFormat.sampleRate
            
            let eq = AVAudioUnitEQ(numberOfBands: 5)
            // High pass filter - remove low rumble
            let hp = eq.bands[0]
            hp.filterType = .highPass
            hp.frequency = 80
            hp.bandwidth = 0.5
            hp.gain = 0
            hp.bypass = false
            
            // Warmth boost in lower mids
            let warmth = eq.bands[1]
            warmth.filterType = .parametric
            warmth.frequency = 400
            warmth.bandwidth = 1.2
            warmth.gain = 2
            warmth.bypass = false
            
            // Reduce harsh frequencies
            let harsh = eq.bands[2]
            harsh.filterType = .parametric
            harsh.frequency = 2000
            harsh.bandwidth = 0.8
            harsh.gain = -3
            harsh.bypass = false
            
            // Soft high shelf
            let shelf = eq.bands[3]
            shelf.filterType = .highShelf
            shelf.frequency = 4000
            shelf.bandwidth = 0.5
            shelf.gain = -4
            shelf.bypass = false
            
            // Gentle low pass
            let lp = eq.bands[4]
            lp.filterType = .lowPass
            lp.frequency = 8000
            lp.bandwidth = 0.7
            lp.gain = 0
            lp.bypass = false
            
            let reverb = AVAudioUnitReverb()
            reverb.loadFactoryPreset(.largeHall)  // More spacious, calming
            reverb.wetDryMix = 35  // More reverb for soothing effect
            
            self.initialFadeInSamples = Int(self.sampleRate * 2.5)  // Longer, gentler fade-in
            self.fadeInSamplesRemaining = self.initialFadeInSamples
            self.lfo1Phase = 0; self.lfo2Phase = 0; self.lfo3Phase = 0; self.tonePhase = 0
            
            let sourceNode = AVAudioSourceNode { _, _, frameCount, audioBufferList in
                let abl = UnsafeMutableAudioBufferListPointer(audioBufferList)
                let twoPi = 2.0 * Double.pi
                
                for buffer in abl {
                    guard let data = buffer.mData else { continue }
                    let ptr = data.bindMemory(to: Float.self, capacity: Int(frameCount))
                    
                    for frame in 0..<Int(frameCount) {
                        // Base source: softer pink noise for soothing effect
                        let white: Float = Float.random(in: -1...1)
                        self.b0 = 0.99765 * self.b0 + 0.0990460 * white
                        self.b1 = 0.96300 * self.b1 + 0.2965164 * white
                        self.b2 = 0.57000 * self.b2 + 1.0526913 * white
                        var pink = self.b0 + self.b1 + self.b2 + 0.1848 * white
                        pink *= 0.025  // Reduced volume for gentler sound
                        
                        // Multiple LFOs for breathing-like, meditative rhythm
                        let lfo1 = self.lfo1Freq
                        let lfo2 = self.lfo2Freq
                        let lfo3 = self.lfo3Freq
                        self.lfo1Phase += twoPi * lfo1 / self.sampleRate
                        self.lfo2Phase += twoPi * lfo2 / self.sampleRate
                        self.lfo3Phase += twoPi * lfo3 / self.sampleRate
                        if self.lfo1Phase > twoPi { self.lfo1Phase -= twoPi }
                        if self.lfo2Phase > twoPi { self.lfo2Phase -= twoPi }
                        if self.lfo3Phase > twoPi { self.lfo3Phase -= twoPi }
                        
                        // Create gentle, breathing-like modulation
                        let breath1 = 1.0 + 0.06 * sin(self.lfo1Phase)
                        let breath2 = 1.0 + 0.04 * sin(self.lfo2Phase + Double.pi/4)
                        let deepRhythm = 1.0 + 0.03 * sin(self.lfo3Phase + Double.pi/2)
                        let lfo = breath1 * breath2 * deepRhythm
                        var sample = Float(lfo) * pink
                        
                        // Add subtle harmonic tone for warmth and musicality
                        self.tonePhase += twoPi * self.toneFreq / self.sampleRate
                        if self.tonePhase > twoPi { self.tonePhase -= twoPi }
                        let fundamental = 0.008 * sin(self.tonePhase)
                        let harmonic = 0.004 * sin(self.tonePhase * 2.0 + Double.pi/6)
                        let tone = fundamental + harmonic
                        sample += Float(tone)
                        
                        // Gentle, soft crackles for soothing effect
                        if self.crackleBurstFramesRemaining > 0 {
                            // Softer crackle with gentle envelope
                            let crackle = Float.random(in: -1...1) * self.crackleBurstAmplitude * 0.6
                            sample += crackle
                            self.crackleBurstAmplitude *= 0.985  // Slower decay for gentler sound
                            self.crackleBurstFramesRemaining -= 1
                        }
                        
                        let x = sample
                        var output = x / (1.0 + abs(x))
                        if self.fadeInSamplesRemaining > 0 && self.initialFadeInSamples > 0 {
                            let progressed = Float(self.initialFadeInSamples - self.fadeInSamplesRemaining)
                            let ramp = max(0.0, min(1.0, progressed / Float(self.initialFadeInSamples)))
                            output *= ramp
                            self.fadeInSamplesRemaining -= 1
                        }
                        ptr[frame] = output
                    }
                }
                return noErr
            }
            
            engine.attach(eq)
            engine.attach(reverb)
            engine.attach(sourceNode)
            
            let format = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: self.sampleRate, channels: hwFormat.channelCount, interleaved: false)
            engine.connect(sourceNode, to: eq, format: format)
            engine.connect(eq, to: reverb, format: format)
            engine.connect(reverb, to: mainMixer, format: format)
            
            do { 
                try engine.start() 
                // Update properties on main thread
                DispatchQueue.main.async {
                    self.audioEngine = engine
                    self.noiseNode = sourceNode
                    self.eqNode = eq
                    self.reverbNode = reverb
                    self.audioEngine?.mainMixerNode.outputVolume = self.masterVolume
                }
            } catch { 
                print("Failed to start audio engine: \(error)") 
            }
        }
    }
    
    private func scheduleCrackles() {
        // More gentle, less frequent crackles for soothing effect
        crackleTimer = Timer.scheduledTimer(withTimeInterval: Double.random(in: 1.5...3.0), repeats: false) { [weak self] _ in
            guard let self = self else { return }
            
            // Ensure we're on the main thread for state updates
            DispatchQueue.main.async {
                self.crackleBurstFramesRemaining = Int(Double.random(in: 200...600))  // Shorter bursts
                self.crackleBurstAmplitude = Float.random(in: 0.008...0.025)  // Much softer
                if self.isPlaying { 
                    self.scheduleCrackles() 
                }
            }
        }
    }
    

    
    deinit {
        stopFireSounds()
    }
}
