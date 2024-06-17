//
//  APIManager.swift
//  Blue
//
//  Created by Blue.

import Foundation
import Alamofire
import AlamofireObjectMapper
import PDFKit

class APIManager {
    
    // ----------------------------------------------------------
    //                       MARK: - Put API Request -
    // ----------------------------------------------------------
    class func postAPIRequestForSendGridEmail(url: String, parameters: [String: Any], completion: @escaping (_ isSuccess: Bool , _ message: String, _ response: Response?) -> Void) {
        
        Alamofire.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: ["Content-Type": "application/json", "Authorization": "Bearer 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"]).responseJSON { (dataResponse) in
            
            print(dataResponse)
            
            if let res = dataResponse.response?.statusCode {
                
                if (200 ..< 299).contains(res) {
                    completion(true, "Success", nil)
                } else {
                    completion(false, "Fail", nil)
                }
                
            } else {
                completion(false, dataResponse.result.error!.localizedDescription, nil)
            }
        }
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Get API Request -
    // ----------------------------------------------------------
    class func getAPIRequest(url: String, completion: @escaping (_ isSuccess: Bool, _ response: [String: Any]?) -> Void) {
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON { (dataResponse) in
            
            print("API URL :: \(url)")
            
            if dataResponse.response?.statusCode == 200 {
                
                if let res = dataResponse.result.value as? [String: Any] {
                    completion(true, res)
                }
                
            } else {
                completion(false, nil)
            }
        }
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Post API Request -
    // ----------------------------------------------------------
    class func postAPIRequest(postURL: String, parameters: [String: Any], completion: @escaping (_ isSuccess: Bool, _ message: String, _ response: Response?) -> Void) {
        
        print("URL :: \(postURL)")
        print("API Parameter :: \(parameters)")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy hh:mm:ss a"//"dd/MM/yyyy HH:mm:ss"
        let formattedDate = dateFormatter.string(from: Date())
        print("API CALLING TIME :: \(formattedDate)")
        
        let uuid = UIDevice.current.identifierForVendor!.uuidString
        let header: HTTPHeaders = ["tkn": "4qasp7eng96d69786tf4mnm9c6a1mo3t" + uuid]
        
        Alamofire.request(postURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: header).responseJSON { (dataResponse) in
            
            print("Response URL :: \(postURL)")
            print("API Parameter :: \(parameters)")
            print("dataResponse :: \(dataResponse)")
            
            if let res = dataResponse.result.value as? [String: Any] {
                print("API CALLING IN PROCESS :: \(formattedDate)")
                let resData = Response(JSON: res)
                print("Response \(postURL): \(String(describing: resData))")
                
                if resData?.status == "Error" && resData?.msg == "Email already Registered" {
                    print("API CALLING END TIME :: \(formattedDate)")
                    completion(true, ((resData!.msg) ?? resData?.message) ?? "", resData)
                    
                } else {
                    
                    if resData?.status == kSuccess {
                        print("API CALLING END TIME :: \(formattedDate)")
                        completion(true, ((resData!.msg) ?? resData?.message) ?? "", resData)
                        
                    } else {
                        
                        if (resData!.msg?.lowercased().contains("login required to access this route") ?? false) || (resData?.msg?.lowercased().contains("error invalid route") ?? false) {
                            UIApplication.shared.windows.last?.rootViewController?.showAlertWithOKButton(message: resData!.msg ?? "", {
                                
                            })
                            
                        } else {
                            completion(false, resData!.msg!, nil)
                        }
                    }
                }
                
            } else if let error = dataResponse.result.error {
                
                print("FAILED API: \(postURL)")
                print("API Parameter :: \(parameters)")
                completion(false, error.localizedDescription, nil)
                
            } else {
                
                print("FAILED API: \(postURL)")
                print("API Parameter :: \(parameters)")
                completion(false, "Unknown error", nil)
            }
        }
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Upload Image API call -
    // ----------------------------------------------------------
    class func UploadImg(postUrl: String, img: UIImage, imgKey: String, parameters: [String: Any], completion: @escaping (_ isSuccess: Bool, _ message: String, _ response: Response?) -> Void) {
        
        print("PostURL :: \(postUrl)")
        
        let uuid = UIDevice.current.identifierForVendor!.uuidString
        let header: HTTPHeaders = ["tkn":"4qasp7eng96d69786tf4mnm9c6a1mo3t" + uuid]
        let imgData = img.jpegData(compressionQuality: 0.5)
        
        Alamofire.upload(multipartFormData: { (MultipartFormData) in
            
            MultipartFormData.append(imgData!, withName: imgKey, fileName: "file.jpg", mimeType: "img/jpg")
            
            for (key, value) in parameters {
                if key != imgKey {
                    MultipartFormData.append((value as! String).data(using: .utf8)!, withName: key)
                }
            }
            
        }, to: postUrl, headers: header) { (response) in
            
            switch response {
                    
                case .success(let upload, _, _):
                    
                    upload.uploadProgress(closure: { (progress) in
                        print("Upload Progress :: \(progress.fractionCompleted)")
                    })
                    
                    upload.responseJSON(completionHandler: { (dataResponse) in
                        
                        print("Profile Image Custom :: \(dataResponse.result)")
                        
                        if let res = dataResponse.result.value as? [String: Any] {
                            
                            let resData = Response(JSON: res)
                            
                            if resData?.status == kSuccess {
                                completion(true,resData!.msg!,resData)
                            } else {
                                completion(false,resData!.msg!,nil)
                            }
                        }
                    })
                    break
                    
                case .failure(let encodingError):
                    completion(false, encodingError.localizedDescription, nil)
            }
        }
    }
    
    // ----------------------------------------------------------
    //                       MARK: - Upload Resume Image API call -
    // ----------------------------------------------------------
    class func UploadResumeImg(postUrl: String, img: Data, _ contentType: String = "jpg", imgKey: String, parameters: [String: Any], completion: @escaping (_ isSuccess: Bool, _ message: String, _ response: Response?) -> Void) {
        
        print("PostURL :: \(postUrl)")
        
        let uuid = UIDevice.current.identifierForVendor!.uuidString
        let header: HTTPHeaders = ["tkn":"4qasp7eng96d69786tf4mnm9c6a1mo3t" + uuid]
        
        Alamofire.upload(multipartFormData: { (MultipartFormData) in
            
            if contentType == "pdf" {
                MultipartFormData.append(img, withName: imgKey, fileName: "file.pdf", mimeType: "img/pdf")
                
            } else if contentType == "pages" {
                MultipartFormData.append(img, withName: imgKey, fileName: "file.pages", mimeType: "img/pages")
                
            } else if contentType == "docx" {
                MultipartFormData.append(img, withName: imgKey, fileName: "file.docx", mimeType: "img/docx")
                
            } else if contentType == "xlsx" {
                MultipartFormData.append(img, withName: imgKey, fileName: "file.xlsx", mimeType: "img/xlsx")
                
            } else {
                MultipartFormData.append(img, withName: imgKey, fileName: "file.jpg", mimeType: "img/jpg")
            }
            
            for (key, value) in parameters {
                if key != imgKey {
                    MultipartFormData.append((value as! String).data(using: .utf8)!, withName: key)
                }
            }
            
        }, to: postUrl, headers: header) { (response) in
            
            switch response {
                    
                case .success(let upload, _, _):
                    
                    upload.uploadProgress(closure: { (progress) in
                        print("Upload Progress :: \(progress.fractionCompleted)")
                    })
                    
                    upload.responseJSON(completionHandler: { (dataResponse) in
                        
                        if let res = dataResponse.result.value as? [String: Any] {
                            
                            let resData = Response(JSON: res)
                            //print(resData!.selfie!)
                            
                            if resData?.status == kSuccess {
                                completion(true,resData!.msg!,resData)
                            } else {
                                completion(false,resData!.msg!,nil)
                            }
                        }
                    })
                    break
                    
                case .failure(let encodingError):
                    completion(false,encodingError.localizedDescription,nil)
            }
        }
    }
    
    class func UploadCardScanImage(url: String, headers: [String: String], parameter: [String: String]?, imgKey: String, imgdata: Data, completion: @escaping (Bool, String, CardScan?) -> Void) {
        
        debugPrint(headers)
        debugPrint(url)
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            
            multipartFormData.append(imgdata, withName: imgKey, fileName: "file.jpg", mimeType: "image/jpg")
            
            for (key, value) in parameter ?? [:] {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            } //Optional for extra parameters
            
        },to: url, headers: headers)
        { (result) in
            
            switch result {
                case .success(let upload, _, _):
                    
                    upload.uploadProgress(closure: { (progress) in
                        print("Upload Progress :: \(progress.fractionCompleted)")
                    })
                    
                    upload.responseJSON { (dataResponse) in
                        
                        debugPrint(dataResponse)
                        if dataResponse.response?.statusCode == 200 {
                            if let res = dataResponse.result.value as? [String:Any] {
                                let resData = CardScan(JSON: res)
                                completion(true, "Success", resData)
                                
                            } else {
                                completion(false, dataResponse.result.error?.localizedDescription ?? "", nil)
                            }
                            
                        } else {
                            completion(false, dataResponse.result.error!.localizedDescription, nil)
                        }
                    }
                    
                case .failure(let encodingError):
                    print(encodingError)
                    completion(false, encodingError.localizedDescription, nil)
            }
        }
    }
}
