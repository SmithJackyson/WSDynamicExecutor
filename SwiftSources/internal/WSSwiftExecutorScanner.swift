//
//  WSSwiftExecutorScanner.swift
//  WSDynamicExecutor
//
//  Created by SmithJackyson on 2026/11/23.
//

import WSExecutorCommon
import WSSwiftExecutorCommon
import MachO

@objc
public class WSSwiftExecutorScanner: NSObject {
  @objc
  public static func loadExecutorsInImage(_ header: UnsafePointer<mach_header_64>) -> [NSNumber: [NSValue]] {
    var result: [NSNumber: [NSValue]] = [:]
    var sectionSize: UInt = 0
    let sectionData = "__DATA".withCString { segmentName in
      "__ws_swift_exec".withCString { sectionName in
        getsectiondata(header, segmentName, sectionName, &sectionSize)
      }
    }
    guard let sectionData = sectionData, sectionSize > 0 else {
      return result
    }
    
    let size = UInt(MemoryLayout<WSTupleExecutorDescriptor>.stride)
    guard sectionSize % size == 0 else {
      assert(false, "[WSDynamicExecutor]: swift section data is missing")
      return result
    }
    
    let sectionPointer = UnsafeMutableRawPointer(sectionData)
    let count = sectionSize / UInt(size)
    
    let descriptorBuffer = UnsafeMutablePointer<WSExecutorDescriptor>.allocate(capacity: Int(count))
    var position = 0
    
    for i in 0..<count {
      let offset = i * size
      let curPointer = sectionPointer.advanced(by: Int(offset))
      let tuplePointer = curPointer.bindMemory(
        to: WSTupleExecutorDescriptor.self,
        capacity: 1
      )
      guard let descriptor = convert(tuplePointer.pointee) else {
        continue
      }
      let slot = descriptorBuffer.advanced(by: position)
      slot.initialize(to: descriptor)
      position += 1
      
      let key = NSNumber(value: descriptor.options.period.rawValue)
      var array = result[key] ?? []
      array.append(NSValue(pointer: UnsafeRawPointer(slot)))
      result[key] = array
    }
    return result
  }
  
  private static func convert(_ swiftDescriptor: WSTupleExecutorDescriptor) -> WSExecutorDescriptor? {
    guard let period = WSExecutorPeriod(rawValue: swiftDescriptor.options.period) else {
      assert(false, "[WSDynamicExecutor]: convert WSSwiftExecutorDescriptor to WSExecutorDescriptor failed, period value illegal")
      return nil
    }
    
    let name = swiftDescriptor.name()
    let priority = swiftDescriptor.options.priority
    let group = swiftDescriptor.options.group()
    let targetClass = swiftDescriptor.options.targetClass()
    let flags = WSExecutorFlags(rawValue: swiftDescriptor.options.flags)
    
    let descriptor = WSExecutorDescriptor(
      name: name,
      options: WSExecutorOptions(
        period: period,
        priority: priority,
        group: group,
        targetClass: targetClass,
        delayTime: swiftDescriptor.options.delayTime,
        timeout: swiftDescriptor.options.timeout,
        flags: flags
      ),
      executor: swiftDescriptor.executor
    )
    return descriptor
  }
}
