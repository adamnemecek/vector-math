//
//  VectorArithmetic.swift
//  VectorMath
//
//  Created by Nathan Perkins on 7/22/16.
//  Copyright © 2016 MaxMo Technologies LLC. All rights reserved.
//

public protocol VectorArithmetic: Vector
{
    // IN-PLACE OPERATORS
    
    mutating func inPlaceNegate()
    
    // self = self + arg
    
    mutating func inPlaceAddScalar(_ scalar: Element)
    mutating func inPlaceAddVector(_ vector: Self)

    // self = self - arg
    
    mutating func inPlaceSubtractScalar(_ scalar: Element)
    mutating func inPlaceSubtractVector(_ vector: Self)

    // self = arg - self
    
    mutating func inPlaceSubtractFromScalar(_ scalar: Element)
    mutating func inPlaceSubtractFromVector(_ vector: Self)
    
    // self = arg * self
    
    mutating func inPlaceMultiplyScalar(_ scalar: Element)
    mutating func inPlaceMultiplyVector(_ vector: Self)
    
    // self = self / arg
    
    mutating func inPlaceDivideScalar(_ scalar: Element)
    mutating func inPlaceDivideVector(_ vector: Self)
    
    // self = arg / self
    
    mutating func inPlaceDivideIntoScalar(_ scalar: Element)
    mutating func inPlaceDivideIntoVector(_ vector: Self)
    
    // OPERATORS
    
    func negate() -> Self
    
    // self + arg
    
    func addScalar(_ scalar: Element) -> Self
    func addVector(_ vector: Self) -> Self
    
    // self - arg
    
    func subtractScalar(_ scalar: Element) -> Self
    func subtractVector(_ vector: Self) -> Self
    
    // arg - self
    
    func subtractFromScalar(_ scalar: Element) -> Self
    func subtractFromVector(_ vector: Self) -> Self
    
    // self * arg
    
    func multiplyScalar(_ scalar: Element) -> Self
    func multiplyVector(_ vector: Self) -> Self
    
    // self / arg
    
    func divideScalar(_ scalar: Element) -> Self
    func divideVector(_ vector: Self) -> Self
    
    // arg / self
    
    func divideIntoScalar(_ scalar: Element) -> Self
    func divideIntoVector(_ vector: Self) -> Self
}

extension VectorArithmetic {
    public func negate() -> Self {
        var ret = Self(copyOf: self)
        ret.inPlaceNegate()
        return ret
    }
    
    public func addScalar(_ scalar: Element) -> Self {
        var ret = Self(copyOf: self)
        ret.inPlaceAddScalar(scalar)
        return ret
    }
    
    public func addVector(_ vector: Self) -> Self {
        var ret = Self(copyOf: self)
        ret.inPlaceAddVector(vector)
        return ret
    }
    
    public func subtractScalar(_ scalar: Element) -> Self {
        var ret = Self(copyOf: self)
        ret.inPlaceSubtractScalar(scalar)
        return ret
    }
    
    public func subtractVector(_ vector: Self) -> Self {
        var ret = Self(copyOf: self)
        ret.inPlaceSubtractVector(vector)
        return ret
    }
    
    public func subtractFromScalar(_ scalar: Element) -> Self {
        var ret = Self(copyOf: self)
        ret.inPlaceSubtractFromScalar(scalar)
        return ret
    }
    
    public func subtractFromVector(_ vector: Self) -> Self {
        var ret = Self(copyOf: self)
        ret.inPlaceSubtractFromVector(vector)
        return ret
    }
    
    public func multiplyScalar(_ scalar: Element) -> Self {
        var ret = Self(copyOf: self)
        ret.inPlaceMultiplyScalar(scalar)
        return ret
    }
    
    public func multiplyVector(_ vector: Self) -> Self {
        var ret = Self(copyOf: self)
        ret.inPlaceMultiplyVector(vector)
        return ret
    }
    
    public func divideScalar(_ scalar: Element) -> Self {
        var ret = Self(copyOf: self)
        ret.inPlaceDivideScalar(scalar)
        return ret
    }
    
    public func divideVector(_ vector: Self) -> Self {
        var ret = Self(copyOf: self)
        ret.inPlaceDivideVector(vector)
        return ret
    }
    
    public func divideIntoScalar(_ scalar: Element) -> Self {
        var ret = Self(copyOf: self)
        ret.inPlaceDivideIntoScalar(scalar)
        return ret
    }
    
    public func divideIntoVector(_ vector: Self) -> Self {
        var ret = Self(copyOf: self)
        ret.inPlaceDivideIntoVector(vector)
        return ret
    }
}

// TODO: implement equatable

public func +=<T: VectorArithmetic, U>(lhs: inout T, rhs: U) where T.Element == U {
    lhs.inPlaceAddScalar(rhs)
}

public func +=<T: VectorArithmetic>(lhs: inout T, rhs: T) {
    lhs.inPlaceAddVector(rhs)
}

public func -=<T: VectorArithmetic, U>(lhs: inout T, rhs: U) where T.Element == U {
    lhs.inPlaceSubtractScalar(rhs)
}

public func -=<T: VectorArithmetic>(lhs: inout T, rhs: T) {
    lhs.inPlaceSubtractVector(rhs)
}

public func *=<T: VectorArithmetic, U>(lhs: inout T, rhs: U) where T.Element == U {
    lhs.inPlaceMultiplyScalar(rhs)
}

public func *=<T: VectorArithmetic>(lhs: inout T, rhs: T) {
    lhs.inPlaceMultiplyVector(rhs)
}

public func /=<T: VectorArithmetic, U>(lhs: inout T, rhs: U) where T.Element == U {
    lhs.inPlaceDivideScalar(rhs)
}

public func /=<T: VectorArithmetic>(lhs: inout T, rhs: T) {
    lhs.inPlaceDivideVector(rhs)
}

public func +<T: VectorArithmetic, U>(lhs: T, rhs: U) -> T where T.Element == U {
    return lhs.addScalar(rhs)
}

public func +<T: VectorArithmetic, U>(lhs: U, rhs: T) -> T where T.Element == U {
    return rhs.addScalar(lhs)
}

public func +<T: VectorArithmetic>(lhs: T, rhs: T) -> T {
    return lhs.addVector(rhs)
}

public func -<T: VectorArithmetic, U>(lhs: T, rhs: U) -> T where T.Element == U {
    return lhs.subtractScalar(rhs)
}

public func -<T: VectorArithmetic, U>(lhs: U, rhs: T) -> T where T.Element == U {
    return rhs.subtractFromScalar(lhs)
}

public func -<T: VectorArithmetic>(lhs: T, rhs: T) -> T {
    return lhs.subtractVector(rhs)
}

public func *<T: VectorArithmetic, U>(lhs: T, rhs: U) -> T where T.Element == U {
    return lhs.multiplyScalar(rhs)
}

public func *<T: VectorArithmetic, U>(lhs: U, rhs: T) -> T where T.Element == U {
    return rhs.multiplyScalar(lhs)
}

public func *<T: VectorArithmetic>(lhs: T, rhs: T) -> T {
    return lhs.multiplyVector(rhs)
}

public func /<T: VectorArithmetic, U>(lhs: T, rhs: U) -> T where T.Element == U {
    return lhs.divideScalar(rhs)
}

public func /<T: VectorArithmetic, U>(lhs: U, rhs: T) -> T where T.Element == U {
    return rhs.divideIntoScalar(lhs)
}

public func /<T: VectorArithmetic>(lhs: T, rhs: T) -> T {
    return lhs.divideVector(rhs)
}
