//
//  InterfaceController.swift
//  App WatchKit Extension
//
//  Created by Tomás Vega on 3/15/20.
//  Copyright © 2020 Augmental Tech. All rights reserved.
//

import WatchKit
import Foundation
import CoreBluetooth
import AVFoundation


class InterfaceController: WKInterfaceController,CBCentralManagerDelegate,CBPeripheralDelegate {

    
    @IBOutlet weak var textIn: WKInterfaceLabel!
    @IBOutlet weak var rssiVal: WKInterfaceLabel!
    @IBOutlet weak var valSlider: WKInterfaceSlider!
    var manager:CBCentralManager!
    var _peripheral:CBPeripheral!
    var audioPlayer = AVAudioPlayer()
    var threshold = 40
    
    @IBAction func sliderAction(_ value: Float) {
        print(value)
        threshold = Int(value)
        rssiVal.setText(String(threshold))
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        print ("Hello Tomás")
        // Configure interface objects here.
        textIn.setText("Disconnected")
        init_device()
    }
    
    
    
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    func init_device() {
        manager = CBCentralManager(delegate: self, queue: nil)
        print ("init device")
//        let filePath = NSBundle.mainBundle().pathForResource("ding", ofType: "m4a")!
//        let fileUrl = NSURL.fileURLWithPath(filePath)
//        let asset = WKAudioFileAsset(URL: fileUrl)
//        let playerItem = WKAudioFilePlayerItem(asset: asset)
//        player = WKAudioFilePlayer(playerItem: playerItem)
//
      }
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == CBManagerState.poweredOn {
            print("Buscando a Marc")
            central.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    
//    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
//    if let power = advertisementData[CBAdvertisementDataTxPowerLevelKey] as? Double{
//       print("Distance is ", pow(10, ((power - Double(truncating: RSSI))/20)))
//       }
//    }
    let NAME = "GVS"
    let UUID_SERVICE = CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
    let UUID_WRITE = CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")
    let UUID_READ = CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")
    var sendCharacteristic: CBCharacteristic!
    var loadedService: Bool = true

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let device = (advertisementData as NSDictionary).object(forKey: CBAdvertisementDataLocalNameKey) as? NSString
        
        print(device ?? "None")
        print(advertisementData)
        
//        let NAME = "Master Of All Pleasure's AirPods"
        if (device == "nil"){
             //print(device, RSSI)
            print("nada pe varón")
        } else if device?.contains(NAME) == true {
            WKInterfaceDevice.current().play(.click)
            // Stop looking for devices
            // Track as connected peripheral
            // Setup delegate for events
            self.manager.stopScan()
            self._peripheral = peripheral
            self._peripheral.delegate = self
            
            // Connect to the perhipheral proper
            manager.connect(peripheral, options: nil)
            debugPrint("Found Bean.")
            textIn.setText("Connected")
//            startRSSIUpdate()
        }
        
    }
    
    
    // Connected to peripheral
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // Ask for services
        peripheral.discoverServices(nil)
        debugPrint("Getting services ...")
    }
    
    // Discovered peripheral services
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        // Look through the service list
        for service in peripheral.services! {
            let thisService = service as CBService
            // If this is the service we want
            if service.uuid == UUID_SERVICE {
                // Ask for specific characteristics
                peripheral.discoverCharacteristics(nil, for: thisService)
            }
            debugPrint("Service: ", service.uuid)
        }
    }
    
    // Discovered peripheral characteristics
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        debugPrint("Enabling ...")
        // Look at provided characteristics
        for characteristic in service.characteristics! {
            let thisCharacteristic = characteristic as CBCharacteristic
            // If this is the characteristic we want
            print(thisCharacteristic.uuid)
            if thisCharacteristic.uuid == UUID_READ {
                // Start listening for updates
                // Potentially show interface
                self._peripheral.setNotifyValue(true, for: thisCharacteristic)
                
                // Debug
                debugPrint("Set to notify: ", thisCharacteristic.uuid)
            } else if thisCharacteristic.uuid == UUID_WRITE {
                sendCharacteristic = thisCharacteristic
                loadedService = true
            }
            debugPrint("Characteristic: ", thisCharacteristic.uuid)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
    //        print(peripheral.identifier)
            // Make sure it is the peripheral we want
        if characteristic.uuid == UUID_READ {
                // Get bytes into string
//            let dataReceived = characteristic.value! as NSData
            self._peripheral.readRSSI() //can only do 1Hz
            
            print(peripheral)
            print(characteristic)
//            print(peripheral.rssi)
                
        }
        
    }
    
//    enum WKHapticType : Int { 
//
//        case Notification 
//        case DirectionUp 
//        case DirectionDown 
//        case Success 
//        case Failure 
//        case Retry 
//        case Start 
//        case Stop 
//        case Click 
//    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        let signal = Int(truncating: RSSI) * -1
        print(signal)
        textIn.setText(String(signal))
        if signal < threshold {
            print("yo")
//            playsound(soundname: "ding")
//            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)

//            WKInterfaceDevice.current().pla\y(.click)
            
            WKInterfaceDevice().play(.success)

        }
    }

    
    var timer = Timer()
    
    func startRSSIUpdate() {
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: (1.0/20.0), target: self, selector: #selector(self.getRSSI), userInfo: nil, repeats: true)
    }
    
    @objc func getRSSI() {
        self._peripheral.readRSSI()
    }
    

    func playsound(soundname:String){

        do {
            audioPlayer = try AVAudioPlayer (contentsOf: URL.init(fileURLWithPath: Bundle.main.path(forResource: "ding", ofType:"mp3")!))
            audioPlayer.prepareToPlay()
        }
        catch {
            //print(error)
        }
        //print("playAudio")
        audioPlayer.play()
    }
//        guard let url = Bundle.main.url(forResource: soundname, withExtension: "mp3") else { return }
//
//        do {
//            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
//            try AVAudioSession.sharedInstance().setActive(true)
//
//            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
//            audioPlayer = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
//
//            /* iOS 10 and earlier require the following line:
//            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileTypeMPEGLayer3) */
//
////            guard let player = audioPlayer else { return }
//
//            audioPlayer.play()
//
//        } catch let error {
//            print(error.localizedDescription)
//        }
//    }
}
