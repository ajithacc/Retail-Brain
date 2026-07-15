//
//  String+Ext.swift
//  RetailBrain
//
//  Created by muhammed.nadeem.m.a on 09/07/26.
//  Copyright © 2026 Accenture. All rights reserved.
//

import Foundation

extension String {

    var trimmed: String {
        self.trimmingCharacters(in: .whitespacesAndNewlines)
    }

}
