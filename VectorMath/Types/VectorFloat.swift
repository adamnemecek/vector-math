//
//  VectorFloat.swift
//  VectorMath
//
//  Created by Nathan Perkins on 6/24/16.
//  Copyright © 2016 MaxMo Technologies LLC. All rights reserved.
//

import Foundation
import Accelerate

public struct VectorFloat: Vector, VectorSummarizable, VectorArithmetic
{
    public typealias Index = Int
    public typealias Element = Float
    
    private var memory: ManagedMemory<Element>
    
    // TODO: INVESTIGATE if there is a performance penalty for this, or if it just gets inlined
    public var count: Index {
        get {
            return memory.length
        }
    }
    public var length: Index {
        get {
            return memory.length
        }
    }
    
    // INITIALIZATION
    
    // used internally to optimize addition / subtraction (skip copy)
    internal init(unfilledOfLength length: Index) {
        precondition(length >= 0, "Length must be positive.")
        
        memory = ManagedMemory<Element>(unfilledOfLength: length)
    }
    
    public init(zerosOfLength length: Index) {
        precondition(length >= 0, "Length must be positive.")
        
        memory = ManagedMemory<Element>(unfilledOfLength: length)
        vDSP_vclr(memory[0], 1, vDSP_Length(length))
    }
    
    public init(copyOf vector: VectorFloat) {
        // will copy on write
        memory = vector.memory
    }
    
    public init(fromArray elements: [Element]) {
        // initialize memory
        memory = ManagedMemory<Element>(unfilledOfLength: elements.count)
        
        // copy elements
        var elements = elements
        let _ = withUnsafePointer(&elements[0]) {
            memcpy(memory[0], $0, sizeof(Element.self) * elements.count)
        }
    }
    
    // PRIVATE
    
    mutating private func ensureUnique() {
        if !isUniquelyReferencedNonObjC(&memory) {
            memory = memory.copy()
        }
    }

    // good idea, and well optimized by compiler
    // RISK: not thread safe
    // if old is not uniquely referenced at first, it may be deinit on another thread
    // since this function will not retain it after returning
//    mutating private func uniquePointerForWriting() -> (read: UnsafePointer<Element>, write: UnsafeMutablePointer<Element>) {
//        if isUniquelyReferencedNonObjC(&memory) {
//            // uniquely referenced memory, use the same pointer
//            let ptr: UnsafeMutablePointer<Element> = memory[0]
//            return (read: UnsafePointer<Element>(ptr), write: ptr)
//        }
//        else {
//            // allocate new memory
//            let old = memory
//            memory = ManagedMemory(unfilledOfLength: old.length)
//            
//            // get pointers
//            let ptrOld: UnsafeMutablePointer<Element> = old[0]
//            let ptrNew: UnsafeMutablePointer<Element> = memory[0]
//            
//            // return both pointers
//            return (read: UnsafePointer<Element>(ptrOld), write: ptrNew)
//        }
//    }
    
    mutating private func ensureUniqueWritableAndReturnReadable() -> ManagedMemory<Element> {
        if isUniquelyReferencedNonObjC(&memory) {
            // uniquely referenced memory, use the same pointer
            return memory
        }
        else {
            // allocate new memory
            let old = memory
            memory = ManagedMemory(unfilledOfLength: old.length)
            return old
        }
    }
    
    private func ensureSameLength(_ vector: VectorFloat) {
        // must have matching lengths
        precondition(memory.length == vector.memory.length, "Vector lengths do not match (\(memory.length) and \(vector.memory.length))")
    }
    
    // ACCESS
    
    public subscript(index: Index) -> Element {
        get {
            return memory[index]
        }
        set {
            // copy before write
            ensureUnique()
            
            // assign
            memory[index] = newValue
        }
    }
    
    // SUMMARIZE
    
    public func sum() -> Element {
        var ret: Element = 0
        vDSP_sve(memory[0], 1, &ret, vDSP_Length(memory.length))
        return ret
    }
    
    public func mean() -> Element {
        var ret: Element = 0
        vDSP_meanv(memory[0], 1, &ret, vDSP_Length(memory.length))
        return ret
    }
    
    public func min() -> Element {
        var ret: Element = 0
        vDSP_minv(memory[0], 1, &ret, vDSP_Length(memory.length))
        return ret
    }
    
    public func max() -> Element {
        var ret: Element = 0
        vDSP_maxv(memory[0], 1, &ret, vDSP_Length(memory.length))
        return ret
    }
    
    // IN-PLACE OPERATORS
    // optimization: rather than ensuringUniqueness, offer two code paths depending on whether
    // the memory is uniquely referenced or not
    
    mutating public func inPlaceNegate() {
        // copy on write
        let read = ensureUniqueWritableAndReturnReadable()
        
        // perform negation
        vDSP_vneg(read[0], 1, memory[0], 1, vDSP_Length(memory.length))
    }
    
    mutating public func inPlaceAddScalar(_ scalar: Element) {
        // copy on write
        let read = ensureUniqueWritableAndReturnReadable()
        
        // perform addition
        var scalar = scalar
        vDSP_vsadd(read[0], 1, &scalar, memory[0], 1, vDSP_Length(memory.length))
    }
    
    mutating public func inPlaceAddVector(_ vector: VectorFloat) {
        // must have matching lengths
        ensureSameLength(vector)
        
        // copy on write
        let read = ensureUniqueWritableAndReturnReadable()
        
        // perform addition
        vDSP_vadd(read[0], 1, vector.memory[0], 1, memory[0], 1, vDSP_Length(memory.length))
    }
    
    mutating public func inPlaceSubtractScalar(_ scalar: Element) {
        // no vDSP subtraction
        inPlaceAddScalar(0 - scalar)
    }
    
    mutating public func inPlaceSubtractVector(_ vector: VectorFloat) {
        // must have matching lengths
        ensureSameLength(vector)
        
        // copy on write
        let read = ensureUniqueWritableAndReturnReadable()
        
        // perform subtraction
        vDSP_vsub(read[0], 1, vector.memory[0], 1, memory[0], 1, vDSP_Length(memory.length))
    }
    
    mutating public func inPlaceMultiplyScalar(_ scalar: Element) {
        // copy on write
        let read = ensureUniqueWritableAndReturnReadable()
        
        // perform multiplication
        var scalar = scalar
        vDSP_vsmul(read[0], 1, &scalar, memory[0], 1, vDSP_Length(memory.length))
    }
    
    mutating public func inPlaceMultiplyVector(_ vector: VectorFloat) {
        // must have matching lengths
        ensureSameLength(vector)
        
        // copy on write
        let read = ensureUniqueWritableAndReturnReadable()
        
        // perform multiplication
        vDSP_vmul(read[0], 1, vector.memory[0], 1, memory[0], 1, vDSP_Length(memory.length))
    }
    
    mutating public func inPlaceDivideScalar(_ scalar: Element) {
        // copy on write
        let read = ensureUniqueWritableAndReturnReadable()
        
        // perform division
        var scalar = scalar
        vDSP_vsdiv(read[0], 1, &scalar, memory[0], 1, vDSP_Length(memory.length))
    }
    
    mutating public func inPlaceDivideVector(_ vector: VectorFloat) {
        // must have matching lengths
        ensureSameLength(vector)
        
        // copy on write
        let read = ensureUniqueWritableAndReturnReadable()
        
        // perform division
        vDSP_vdiv(vector.memory[0], 1, read[0], 1, memory[0], 1, vDSP_Length(memory.length))
    }
    
    // NON IN-PLACE OPERATORS
    // Vector provides default implementations that use a copy, then the in place operator
    // directly implementing these produce about a ~15% performance benefit
    
    public func addScalar(_ scalar: Element) -> VectorFloat {
        // create return object
        let ret = VectorFloat(unfilledOfLength: memory.length)
        
        // perform addition
        var scalar = scalar
        vDSP_vsadd(memory[0], 1, &scalar, ret.memory[0], 1, vDSP_Length(memory.length))
        return ret
    }
    
    public func addVector(_ vector: VectorFloat) -> VectorFloat {
        // must have matching lengths
        ensureSameLength(vector)
        
        // create return object
        let ret = VectorFloat(unfilledOfLength: memory.length)
        
        // perform addition
        vDSP_vadd(memory[0], 1, vector.memory[0], 1, ret.memory[0], 1, vDSP_Length(memory.length))
        return ret
    }
    
    public func subtractScalar(_ scalar: Element) -> VectorFloat {
        // no vDSP subtraction
       return addScalar(0 - scalar)
    }
    
    public func subtractVector(_ vector: VectorFloat) -> VectorFloat {
        // must have matching lengths
        ensureSameLength(vector)
        
        // create return object
        let ret = VectorFloat(unfilledOfLength: memory.length)
        
        // perform addition
        vDSP_vsub(vector.memory[0], 1, memory[0], 1, ret.memory[0], 1, vDSP_Length(memory.length))
        return ret
    }
    
    public func multiplyScalar(_ scalar: Element) -> VectorFloat {
        // create return object
        let ret = VectorFloat(unfilledOfLength: memory.length)
        
        // perform addition
        var scalar = scalar
        vDSP_vsmul(memory[0], 1, &scalar, ret.memory[0], 1, vDSP_Length(memory.length))
        return ret
    }
    
    public func multiplyVector(_ vector: VectorFloat) -> VectorFloat {
        // must have matching lengths
        ensureSameLength(vector)
        
        // create return object
        let ret = VectorFloat(unfilledOfLength: memory.length)
        
        // perform addition
        vDSP_vmul(memory[0], 1, vector.memory[0], 1, ret.memory[0], 1, vDSP_Length(memory.length))
        return ret
    }
    
    public func divideScalar(_ scalar: Element) -> VectorFloat {
        // create return object
        let ret = VectorFloat(unfilledOfLength: memory.length)
        
        // perform addition
        var scalar = scalar
        vDSP_vsdiv(memory[0], 1, &scalar, ret.memory[0], 1, vDSP_Length(memory.length))
        return ret
    }
    
    public func divideVector(_ vector: VectorFloat) -> VectorFloat {
        // must have matching lengths
        ensureSameLength(vector)
        
        // create return object
        let ret = VectorFloat(unfilledOfLength: memory.length)
        
        // perform addition
        vDSP_vdiv(vector.memory[0], 1, memory[0], 1, ret.memory[0], 1, vDSP_Length(memory.length))
        return ret
    }
}

