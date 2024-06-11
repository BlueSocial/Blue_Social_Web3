//
//  QRCodeWidgetEntryView.swift
//  Blue
//
//  Created by Blue.

import SwiftUI
import WidgetKit

struct QRCodeWidgetEntryView: View {
    var entry: Provider.Entry

    @Environment(\.widgetFamily) var family

    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall:
            QRCodeSmallWidgetView()

        default:
            fatalError()
        }
    }
}
