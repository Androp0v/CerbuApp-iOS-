//
//  QRScannerViewController.swift
//  CerbuApp
//
//  Created by Raúl Montón Pinillos on 14/9/20.
//  Copyright © 2020 Raúl Montón Pinillos. All rights reserved.
//

import UIKit
import Firebase

protocol QRScannerViewControllerDelegate: class {
    func updateLocalDelta(room: String)
}

class QRScannerViewController: UIViewController, QRScannerViewDelegate {
    @IBOutlet weak var QRScannerView: QRScannerView!
    @IBOutlet weak var errorOverlay: UIView!
    
    weak var delegate: QRScannerViewControllerDelegate?

    let defaults = UserDefaults.standard
    
    // Define QR code strings
    let SALA_POLIVALENTE_QR = "gNc98aMN"
    let SALA_DE_LECTURA_QR = "tHWL45Pg"
    let BIBLIOTECA_QR = "gFJtN3HS"
    let GIMNASIO_QR = "ATPi0bjz"
    let OUT_QR = "SVOWE1Kd"
    
    var databaseReference: DatabaseReference!
    
    private func blurErrorOverlayBackground(){
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = errorOverlay.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        errorOverlay.addSubview(blurEffectView)
        errorOverlay.sendSubviewToBack(blurEffectView)
    }
    
    // Function to close QR Scanner when an error is encountered
    private func errorAndExitQRScanner(){
        errorOverlay.isHidden = false
        blurErrorOverlayBackground()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func updateCheckIn(QRString: String){
        
        let userID = defaults.object(forKey: "userID") as! String
        let epoch = NSDate().timeIntervalSince1970
        
        databaseReference.child(userID).observeSingleEvent(of: .value, with: { (userCheckIn) in
            if userCheckIn.exists(){
                // User had already checked-in
                self.databaseReference.child(userID).setValue([
                                                                "Room": QRString,
                                                                "Time": epoch
                ])
            }else{
                // User hadn't checked-in
                self.databaseReference.child(userID).setValue([
                                                                "Room": QRString,
                                                                "Time": epoch
                ])
            }
        })
    }
    
    private func checkOut(){
        
        let userID = defaults.object(forKey: "userID") as! String
        databaseReference.child(userID).removeValue()
    }
    
    // QRScannerView delegate protocol implementation
    
    func qrScanningDidFail() {
        errorAndExitQRScanner()
    }
    
    func qrScanningSucceededWithCode(code: String?) {
        if code == SALA_POLIVALENTE_QR{
            dismiss(animated: true, completion: nil)
            updateCheckIn(QRString: "SalaPolivalente")
            delegate?.updateLocalDelta(room: "SalaPolivalente")
        }else if code == SALA_DE_LECTURA_QR{
            dismiss(animated: true, completion: nil)
            updateCheckIn(QRString: "SalaDeLectura")
            delegate?.updateLocalDelta(room: "SalaDeLectura")
        }else if code == BIBLIOTECA_QR{
            dismiss(animated: true, completion: nil)
            updateCheckIn(QRString: "Biblioteca")
            delegate?.updateLocalDelta(room: "Biblioteca")
        }else if code == GIMNASIO_QR{
            dismiss(animated: true, completion: nil)
            updateCheckIn(QRString: "Gimnasio")
            delegate?.updateLocalDelta(room: "Gimnasio")
        }else if code == OUT_QR{
            dismiss(animated: true, completion: nil)
            delegate?.updateLocalDelta(room: "Out")
            checkOut()
        }else{
            errorAndExitQRScanner()
        }
    }
    
    func qrScanningDidStop() {
        // Do nothing
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        QRScannerView.delegate = self
        databaseReference = Database.database().reference().child("Capacities/Check-ins")
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
