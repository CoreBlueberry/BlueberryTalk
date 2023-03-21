//
//  BlueberryChatService.swift
//  BlueberryKit
//
//  Created by 허성진 on 2023/03/22.
//

import CoreBluetooth

public class BlueberryChatService: NSObject, ObservableObject {
    
    @Published public var discoveredPeripheral: [PeripheralScanInfo] = []
    @Published public var isPeripheralManagerOn: Bool = false
    
    @Published public var messages: [Message] = []
    @Published public var isPeripheralConnected: Bool = false
//    @Published var peripheralUserInfo: UserInfo?
    var connectedPeripheral: CBPeripheral?
    var messageCharacteristic: CBCharacteristic?
    
    var currentService: CBMutableService?
    
    
    // MARK: - CentralManager Variables
    private var centralManager: CBCentralManager!
    private(set) var centralManagerState: CBManagerState = .unknown {
        didSet {
            print("state: \(centralManagerState.description)")
        }
    }
    
    // MARK: - PeripheralManager Variables
    private var peripheralManager: CBPeripheralManager!
    private(set) var peripheralManagerState: CBManagerState = .unknown {
        didSet {
            print("state: \(peripheralManagerState.description)")
        }
    }
    
    public override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        
        initService()
    }
}

// MARK: - CBCentralManager
extension BlueberryChatService: CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        centralManagerState = central.state
    }
    
    public func startScan() {
        discoveredPeripheral = []
        
        if (centralManagerState == .poweredOn) {
            self.centralManager.scanForPeripherals(
                withServices: [ChatBleSpec.serviceUUID],
                options: [CBCentralManagerRestoredStateScanOptionsKey: true]
            )
        }
    }
    
    func connect(uuid: UUID) {
        guard let p = centralManager.retrievePeripherals(withIdentifiers: [uuid]).first
        else {
//            //TODO: BluetoothManagerError???? 다음에 잘 나눠보자
//            let error = BluetoothManagerError.cannotFindPeripheral
//            log.error(tag: .ble, error.localizedDescription)
//            deviceDelegate?.deviceDidFailToConnect(error)
//            self.updateConnectState(.disconnected)
            return
        }
        
        centralManager.connect(p, options: nil)
    }
    
    public func connect(peripheral: CBPeripheral) {
        centralManager.connect(peripheral, options: nil)
    }
    
    public func disconnect() {
        guard let connectedPeripheral = connectedPeripheral else { return }
        centralManager.cancelPeripheralConnection(connectedPeripheral)
        self.messages = []
    }
    
    public func centralManager(
        _ central: CBCentralManager,
        didConnect peripheral: CBPeripheral
    ) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        connectedPeripheral = peripheral
        
        isPeripheralConnected = true
    }
    
    public func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String : Any],
        rssi RSSI: NSNumber
    ) {
        print("⭐️ didDiscover: \(peripheral.description)")
        print("⭐️ advertisementData: \(advertisementData.description)")
        
        let duplicatedPeripheral =  self.discoveredPeripheral.map { return $0.peripheral }.first(where: { $0.identifier == peripheral.identifier })
        guard duplicatedPeripheral == nil else { return }
        guard let name = advertisementData[CBAdvertisementDataLocalNameKey] as? String else { return }
        
        let model = PeripheralScanInfo(
            peripheral: peripheral,
            name: name,
            advertisenemtData: advertisementData,
            rssi: RSSI
        )
        discoveredPeripheral.append(model)
        discoveredPeripheral.sort { $0.rssi > $1.rssi }
    }
    
    public func centralManager(
        _ central: CBCentralManager,
        didDisconnectPeripheral peripheral: CBPeripheral,
        error: Error?
    ) {
        print("didDisconnectPeripheral: \(peripheral.description)")
        isPeripheralConnected = false
    }
}


extension BlueberryChatService: CBPeripheralDelegate {
    public func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverServices error: Error?
    ) {
        guard let services = peripheral.services else {
            print("Error: didDiscoverServices, service guard let binding failure")
            return
        }
        
        print("Peripheral didDiscoverServices, service found")
        
        services.forEach { service in
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    public func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error: Error?
    ) {
        guard let characteristics = service.characteristics else { return }
        print("Peripheral didDiscoverCharacteristicsFor service: \(service)")
        print("\(service)'s Characteristics: \(characteristics)")
        
        if let characteristic = characteristics.first(where: {
            $0.uuid.isEqual(ChatBleSpec.rxUUID)
        }) {
            self.messageCharacteristic = characteristic
//            if let messageText = messageTextField.text {
//                let data = messageText.data(using: .utf8)
//                peripheral.writeValue(data!, for: characteristic, type: CBCharacteristicWriteType.withResponse)
//                appendMessageToChat(message: Message(text: messageText, isSent: true))
//                messageTextField.text = ""
//
//            }
        }
    }
    
    public func sendMessage(text: String) {
        guard let data = text.data(using: .utf8) else { return }
        guard let messageCharacteristic = messageCharacteristic else { return }
        connectedPeripheral?.writeValue(data, for: messageCharacteristic, type: .withResponse)
        
        let message = Message(text: text, received: false, timestamp: Date())
        messages.append(message)
    }
}



//MARK: - CBPeripheral
extension BlueberryChatService: CBPeripheralManagerDelegate {
    public func startAdvertising(userInfo: UserInfo) {
        if (peripheralManagerState == .poweredOn) {
            print("Peripheral 서비스 시작")
            updateAdvertisingData(userInfo: userInfo)
            initService()
            
            isPeripheralManagerOn = true
        }
    }
    
    private func initService() {
        let serialService = CBMutableService(type: ChatBleSpec.serviceUUID, primary: true)
        let rx = CBMutableCharacteristic(type: ChatBleSpec.rxUUID, properties: ChatBleSpec.rxProperties, value: nil, permissions: ChatBleSpec.rxPermissions)
        serialService.characteristics = [rx]
    
        self.currentService = serialService
        
        peripheralManager.add(serialService)
    }
    
    public func endAdvertising() {
        peripheralManager.stopAdvertising()
        
        guard let service = currentService else { return }
        peripheralManager.remove(service)
        
        isPeripheralManagerOn = false
    }
    
    func updateAdvertisingData(userInfo: UserInfo) {
        let advertisementData = String(format: "%@|%@", userInfo.name, userInfo.description)
        
        peripheralManager.startAdvertising([
            CBAdvertisementDataServiceUUIDsKey: [ChatBleSpec.serviceUUID],
            CBAdvertisementDataLocalNameKey: advertisementData
        ])
    }
    
    public func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        peripheralManagerState = peripheral.state
    }
    
    public func peripheralManager(
        _ peripheral: CBPeripheralManager,
        didReceiveWrite requests: [CBATTRequest]
    ) {
        for request in requests {
            guard let connectedPeripheral = connectedPeripheral else { return }
            guard connectedPeripheral.identifier == request.central.identifier else { return }
            if let value = request.value {
                let messageText = String(data: value, encoding: String.Encoding.utf8) as String?
                print("메세지가 왔습니다 : \(messageText!)")
                
                let message = Message(text: messageText ?? "nil", received: true, timestamp: Date())
                messages.append(message)
            }
            self.peripheralManager.respond(to: request, withResult: .success)
        }
    }
}
