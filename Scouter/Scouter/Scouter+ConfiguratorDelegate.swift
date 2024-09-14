//
//  Scouter+ConfiguratorDelegate.swift
//  Scouter
//
//  Created by Jon Alaniz on 9/14/24.
//

import Foundation

extension Scouter: ConfiguratorDelegate {
    func configurationChanged() {
        timer?.invalidate()
        restart()
    }
}
