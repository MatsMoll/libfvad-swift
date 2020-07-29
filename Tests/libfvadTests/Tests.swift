import libfvad
import XCTest
import AVFoundation

class Tests: XCTestCase {

    func testSetAgressiveness() {
        let detector = VoiceActivityDetector()!
        detector.agressiveness = .veryAggressive
        XCTAssertEqual(detector.agressiveness, .veryAggressive)
        detector.agressiveness = .aggressive
        XCTAssertEqual(detector.agressiveness, .aggressive)
        detector.agressiveness = .lowBitRate
        XCTAssertEqual(detector.agressiveness, .lowBitRate)
        detector.agressiveness = .quality
        XCTAssertEqual(detector.agressiveness, .quality)
    }


    func testSetSampleRate() {
        let detector = VoiceActivityDetector()!
        detector.sampleRate = 48000
        XCTAssertEqual(detector.sampleRate, 48000)
        detector.sampleRate = 32000
        XCTAssertEqual(detector.sampleRate, 32000)
        detector.sampleRate = 16000
        XCTAssertEqual(detector.sampleRate, 16000)
        detector.sampleRate = 8000
        XCTAssertEqual(detector.sampleRate, 8000)
    }

    func testDetectSampleBuffer() {
        let settings: [String : Any] = [
          AVFormatIDKey: Int(kAudioFormatLinearPCM),
          AVLinearPCMBitDepthKey: 16,
          AVLinearPCMIsBigEndianKey: false,
          AVLinearPCMIsFloatKey: false,
          AVLinearPCMIsNonInterleaved: false,
          AVNumberOfChannelsKey: 1,
          AVSampleRateKey: 8000,
        ]
        let thisSourceFile = URL(fileURLWithPath: #file)
        let thisDirectory = thisSourceFile.deletingLastPathComponent()
        let path = thisDirectory.appendingPathComponent("3722.mp3")
        let reader = try! AudioTrackReader(audioPath: path.relativePath, timeRange: nil, settings: settings)

        CMSampleBufferInvalidate(reader.next()!) // skip the first iteration
        let sampleBuffer = reader.next()!

        XCTAssertNotNil(sampleBuffer)

        let detector = VoiceActivityDetector()!
        guard let activities = detector.detect(sampleBuffer: sampleBuffer, byEachMilliSec: 10, duration: 30) else {
          XCTFail()
          return
        }

        let presentationTimeStamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
        XCTAssertGreaterThan(presentationTimeStamp.seconds, 0)

        XCTAssertEqual(activities.count, 3)
        XCTAssertEqual(activities[2].timestamp, 20)
        XCTAssertEqual(activities[2].presentationTimestamp.seconds, presentationTimeStamp.seconds + 0.020)
        CMSampleBufferInvalidate(sampleBuffer)
    }
}
