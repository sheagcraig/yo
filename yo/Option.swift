/*
 * Option.swift
 * Copyright (c) 2014 Ben Gollmer.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 * The base class for a command-line option.
 */
open class Option {
  open let shortFlag: String?
  open let longFlag: String?
  open let required: Bool
  open let helpMessage: String

  /** True if the option was set when parsing command-line arguments */
  open var wasSet: Bool {
    return false
  }

  open var flagDescription: String {
    switch (shortFlag, longFlag) {
    case (let sf, let lf) where sf != nil && lf != nil:
      return "\(ShortOptionPrefix)\(sf!), \(LongOptionPrefix)\(lf!)"
    case (_, let lf) where lf != nil:
      return "\(LongOptionPrefix)\(lf!)"
    default:
      return "\(ShortOptionPrefix)\(shortFlag!)"
    }
  }

  fileprivate init(_ shortFlag: String?, _ longFlag: String?, _ required: Bool, _ helpMessage: String) {
    if let sf = shortFlag {
      assert(sf.characters.count == 1, "Short flag must be a single character")
      assert(Int(sf) == nil && sf.toDouble() == nil, "Short flag cannot be a numeric value")
    }

    if let lf = longFlag {
      assert(Int(lf) == nil && lf.toDouble() == nil, "Long flag cannot be a numeric value")
    }

    self.shortFlag = shortFlag
    self.longFlag = longFlag
    self.helpMessage = helpMessage
    self.required = required
  }

  /* The optional casts in these initalizers force them to call the private initializer. Without
   * the casts, they recursively call themselves.
   */

  /** Initializes a new Option that has both long and short flags. */
  public convenience init(shortFlag: String, longFlag: String, required: Bool = false, helpMessage: String) {
    self.init(shortFlag as String?, longFlag, required, helpMessage)
  }

  /** Initializes a new Option that has only a short flag. */
  public convenience init(shortFlag: String, required: Bool = false, helpMessage: String) {
    self.init(shortFlag as String?, nil, required, helpMessage)
  }

  /** Initializes a new Option that has only a long flag. */
  public convenience init(longFlag: String, required: Bool = false, helpMessage: String) {
    self.init(nil, longFlag as String?, required, helpMessage)
  }

  func flagMatch(_ flag: String) -> Bool {
    return flag == shortFlag || flag == longFlag
  }

  func setValue(_ values: [String]) -> Bool {
    return false
  }
}

/**
 * A boolean option. The presence of either the short or long flag will set the value to true;
 * absence of the flag(s) is equivalent to false.
 */
open class BoolOption: Option {
  fileprivate var _value: Bool = false

  open var value: Bool {
    return _value
  }

  override open var wasSet: Bool {
    return _value
  }

  override func setValue(_ values: [String]) -> Bool {
    _value = true
    return true
  }
}

/**  An option that accepts a positive or negative integer value. */
open class IntOption: Option {
  fileprivate var _value: Int?

  open var value: Int? {
    return _value
  }

  override open var wasSet: Bool {
    return _value != nil
  }

  override func setValue(_ values: [String]) -> Bool {
    if values.count == 0 {
      return false
    }

    if let val = Int(values[0]) {
      _value = val
      return true
    }

    return false
  }
}

/**
 * An option that represents an integer counter. Each time the short or long flag is found
 * on the command-line, the counter will be incremented.
 */
open class CounterOption: Option {
  fileprivate var _value: Int = 0

  open var value: Int {
    return _value
  }

  override open var wasSet: Bool {
    return _value > 0
  }

  override func setValue(_ values: [String]) -> Bool {
    _value += 1
    return true
  }
}

/**  An option that accepts a positive or negative floating-point value. */
open class DoubleOption: Option {
  fileprivate var _value: Double?

  open var value: Double? {
    return _value
  }

  override open var wasSet: Bool {
    return _value != nil
  }

  override func setValue(_ values: [String]) -> Bool {
    if values.count == 0 {
      return false
    }

    if let val = values[0].toDouble() {
      _value = val
      return true
    }

    return false
  }
}

/**  An option that accepts a string value. */
open class StringOption: Option {
  fileprivate var _value: String? = nil

  open var value: String? {
    return _value
  }

  override open var wasSet: Bool {
    return _value != nil
  }

  override func setValue(_ values: [String]) -> Bool {
    if values.count == 0 {
      return false
    }

    _value = values[0]
    return true
  }
}

/**  An option that accepts one or more string values. */
open class MultiStringOption: Option {
  fileprivate var _value: [String]?

  open var value: [String]? {
    return _value
  }

  override open var wasSet: Bool {
    return _value != nil
  }

  override func setValue(_ values: [String]) -> Bool {
    if values.count == 0 {
      return false
    }

    _value = values
    return true
  }
}

/** An option that represents an enum value. */
open class EnumOption<T:RawRepresentable>: Option where T.RawValue == String {
  fileprivate var _value: T?
  open var value: T? {
    return _value
  }

  override open var wasSet: Bool {
    return _value != nil
  }

  /* Re-defining the intializers is necessary to make the Swift 2 compiler happy, as
   * of Xcode 7 beta 2.
   */

  fileprivate override init(_ shortFlag: String?, _ longFlag: String?, _ required: Bool, _ helpMessage: String) {
    super.init(shortFlag, longFlag, required, helpMessage)
  }

  /** Initializes a new Option that has both long and short flags. */
  public convenience init(shortFlag: String, longFlag: String, required: Bool = false, helpMessage: String) {
    self.init(shortFlag as String?, longFlag, required, helpMessage)
  }

  /** Initializes a new Option that has only a short flag. */
  public convenience init(shortFlag: String, required: Bool = false, helpMessage: String) {
    self.init(shortFlag as String?, nil, required, helpMessage)
  }

  /** Initializes a new Option that has only a long flag. */
  public convenience init(longFlag: String, required: Bool = false, helpMessage: String) {
    self.init(nil, longFlag as String?, required, helpMessage)
  }

  override func setValue(_ values: [String]) -> Bool {
    if values.count == 0 {
      return false
    }

    if let v = T(rawValue: values[0]) {
      _value = v
      return true
    }

    return false
  }
}
