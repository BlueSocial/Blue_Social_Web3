//
//  Blue_WidgetBundle.swift
//  Blue
//
//  Created by Blue.

import WidgetKit
import SwiftUI

@main
struct Blue_WidgetBundle: Widget {
    let kind: String = "Blue_WidgetBundle"

    var body: some WidgetConfiguration {
        
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            QRCodeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Blue Social QRCode Widget")
        .description("Instantly share your QRCode from your home screen.")
        .supportedFamilies([.systemSmall]) //, .systemMedium])
    }
}
        
