//
//  ViewController.swift
//  Watchtest
//
//  Created by Tomás Vega on 3/15/20.
//  Copyright © 2020 Augmental Tech. All rights reserved.
//

import UIKit
import CoreBluetooth
import AVFoundation
var audioPlayer = AVAudioPlayer()


class ViewController: UIViewController,CBCentralManagerDelegate,CBPeripheralDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == CBManagerState.poweredOn {
            //print("Buscando a Marc")
            central.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    
    func init_device() {
          manager = CBCentralManager(delegate: self, queue: nil)
          //print ("init device")
      }
    
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        let device = (advertisementData as NSDictionary).object(forKey: CBAdvertisementDataLocalNameKey) as? NSString
        print(advertisementData)
        let signal = Int(truncating: RSSI)
        
        if (device == "nil"){
            //print(device, RSSI)
        }
        print(device, signal)
        // Check if this is the device we want
        if (signal >= -48) {
            //print(device, RSSI)
            //playsound(soundname: "ding")
        }
        
        
        if (signal >= -50) {
//            print(device ?? "None", RSSI)
        }
        
        let NAME = "Master Of All Pleasure's AirPods"
        
        if device?.contains(NAME) == true {
            // Stop looking for devices
            // Track as connected peripheral
            // Setup delegate for events
            self.manager.stopScan()
            self._peripheral = peripheral
            self._peripheral.delegate = self
            
            // Connect to the perhipheral proper
            manager.connect(peripheral, options: nil)
            debugPrint("Found Bean.")
        }
        
    }
    
    func playsound(soundname:String){
        do {
            audioPlayer = try AVAudioPlayer (contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: soundname, ofType:"mp3")!))
            audioPlayer.prepareToPlay()
        }
        catch {
            //print(error)
        }
        //print("playAudio")
        audioPlayer.play()
    }
    
    var manager:CBCentralManager!
    var _peripheral:CBPeripheral!
    var sendCharacteristic: CBCharacteristic!

    override func viewDidLoad() {
        print ("test")
        init_device()
    }
    
}

