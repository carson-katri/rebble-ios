//
//  ByteBuffer.swift
//  ConfidoIOS
//
//  Created by Rudolph van Graan on 25/09/2015.
//
//

import Foundation

public typealias Byte = UInt8

public enum BufferError : Error, CustomStringConvertible {
    case wordLengthMismatch
    
    public var description: String {
        switch self {
        case .wordLengthMismatch: return "WordLengthMismatch"
        }
    }
}


//TODO: Split the struct in two and adopt the protocols below to create a MutableBuffer
public protocol ByteBufferType {
    var values: [Byte] { get }
    //    init()
    //    init(size: Int)
    //    init(bytes: [T])
    //    init(buffer: Self)
    //    init(data: NSData) throws
    //    init(hexData: String) throws
    var size: Int { get }
    var data: Data { get }
    var base64String: String  { get }
    var hexString: String { get }
}
/**
 public protocol ImmutableBufferType: BufferType {
 var memory: UnsafeBufferPointer<Byte> { get }
 }
 
 public protocol MutableBufferType: BufferType {
 var memory: UnsafeMutableBufferPointer<Byte> { get }
 var size: Int { get set }
 mutating func append(bytes: [T])
 }
 */

public struct ByteBuffer {
    public fileprivate(set) var values: [Byte]
    
    public var pointer: UnsafePointer<Byte> {
        get {
            return UnsafePointer<Byte>(values)
        }
    }
    public var mutablePointer: UnsafeMutablePointer<Byte> {
        get {
            return UnsafeMutablePointer<Byte>(mutating: values)
        }
    }
    public var bufferPointer: UnsafeBufferPointer<Byte> {
        get {
            return UnsafeBufferPointer<Byte>(start: UnsafeMutablePointer(mutating: values), count: self.byteCount)
        }
    }
    public var voidPointer: UnsafeRawPointer {
        get {
            return UnsafeRawPointer(values)
        }
    }
    
    public init() {
        values = []
    }
    public init(size: Int) {
        values = [Byte](repeating: 0, count: size)
    }
    public init(bytes: [Byte]) {
        self.values = bytes
    }
    //TODO:  public init<B where B:BufferType, B.T == T>(buffer: B)
    public init(_ buffer: ByteBuffer) {
        self.values = buffer.values
    }
    public init(data: Data) throws {
        let numberOfWords = data.count / MemoryLayout<Byte>.size
        if data.count % MemoryLayout<Byte>.size != 0 {
            throw BufferError.wordLengthMismatch
        }
        self.init(size: numberOfWords)
        (data as NSData).getBytes(&values, length:data.count)
    }
    public init(hexData: String) throws {
        let data = NSMutableData()
        var temp = ""
        for char in hexData.characters {
            temp+=String(char)
            if(temp.characters.count == 2) {
                let scanner = Scanner(string: temp)
                var value: UInt32 = 0
                scanner.scanHexInt32(&value)
                data.append(&value, length: 1)
                temp = ""
            }
            
        }
        try self.init(data: data as Data)
    }
    public var data: Data {
        get { return Data(bytes: UnsafePointer<UInt8>(values), count: byteCount) }
    }
    public var base64String: String {
        get { return data.base64EncodedString(options: []) }
    }
    public var hexString: String {
        get {
            var hexString = ""
            self.bufferPointer.forEach { (byte) -> () in
                hexString.append(String(format:"%02x", byte))
            }
            return hexString
        }
    }
    public var size: Int {
        get {
            return values.count
        }
        set {
            if newValue < values.count {
                //truncate the buffer to the new size
                values = Array(values[0..<newValue])
            } else if newValue > values.count {
                let newBuffer = [Byte](repeating: 0, count: newValue)
                let newBufferPointer = UnsafeMutablePointer<Byte>(mutating: newBuffer)
                newBufferPointer.moveInitialize(from: self.mutablePointer, count: values.count)
                values = newBuffer
            }
        }
    }
    public var byteCount: Int {
        get {
            return values.count * elementSize
        }
    }
    
    public mutating func append(_ bytes: [Byte])  {
        let currentSize = self.size
        let newSize = self.size + bytes.count
        self.size = newSize
        let appendLocation = self.mutablePointer.advanced(by: currentSize)
        appendLocation.moveAssign(from: UnsafeMutablePointer(mutating: bytes), count: bytes.count)
        
    }
    public var elementSize: Int {
        get {
            return MemoryLayout<Byte>.size
        }
    }
}
