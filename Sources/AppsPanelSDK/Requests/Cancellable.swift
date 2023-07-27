//
//  Cancellable.swift
//  AppsPanelSDK
//
//  Created by Arnaud Olivier on 03/09/2018.
//  Copyright © 2018 Apps Panel. All rights reserved.
//

import Alamofire
import UIKit

public protocol Cancellable {

    /// A Boolean value stating whether a request is cancelled.
    var isCancelled: Bool { get }

    /// Cancels the represented request.
    func cancel()

}

class CancellableToken: Cancellable {

    private let request: Alamofire.Request
    private(set) var isCancelled: Bool = false

    private var lock = DispatchSemaphore(value: 1)

    func cancel() {
        _ = lock.wait(timeout: DispatchTime.distantFuture)
        defer { lock.signal() }
        guard !isCancelled else { return }

        isCancelled = true
        request.cancel()
    }

    init(request: Alamofire.Request) {
        self.request = request
    }

}

class DummyCancellable: Cancellable {

    var isCancelled = false

    func cancel() {
        isCancelled = true
    }

}
