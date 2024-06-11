//
//  QRCodeSmallWidgetView.swift
//  Blue
//
//  Created by Blue.

import SwiftUI
import WidgetKit

struct QRCodeSmallWidgetView: View {
    
    // Create the UserDefaults suites for Widget
    let appWidgetSuite = UserDefaults(suiteName: "group.social.blue.app.Blue-Widget")
    
    var body: some View {
        
        ZStack {
            
            // widget content
            if let userURL = appWidgetSuite?.string(forKey: "BlueUserWidgetQRCode") {
                
                let imgQR = UIImage.generateQRCodeFromString(barcode: userURL)
                
                //let qrImage = UIImage().convert(imgQR)
                
                let qrImageWithAppLogo = UIImage().addAppLogoToQRCodeInWidget(qrCodeImage: imgQR ?? UIImage(), logoImage: UIImage(named: "ic_qr_logo"))
                
                // Here Pass qrImage | qrImageWithAppLogo
                Image(uiImage: qrImageWithAppLogo)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    //.padding(15)
            } else {
                Text("Add Blue QR")
            }
        }
        .widgetBackground(Color(UIColor.systemBackground))
    }
}

struct QRCodeSmallWidgetView_Previews: PreviewProvider {
    static var previews: some View {
        QRCodeSmallWidgetView()
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

extension View {
    func widgetBackground(_ backgroundView: some View) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            return containerBackground(for: .widget) {
                backgroundView
            }
        } else {
            return background(backgroundView)
        }
    }
}
