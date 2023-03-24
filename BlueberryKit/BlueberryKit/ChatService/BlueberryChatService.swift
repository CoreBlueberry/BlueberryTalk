//
//  BlueberryChatService.swift
//  BlueberryKit
//
//  Created by 허성진 on 2023/03/22.
//

import CoreBluetooth

public class BlueberryChatService: NSObject, ObservableObject {
    
    /// 채팅 상대 목록 UI에 반영
    @Published public var discoveredPeripheral: [PeripheralScanInfo] = []
    @Published public var isPeripheralManagerOn: Bool = false
    
    /// 채팅방 UI에 반영
    @Published public var messages: [Message] = []
    @Published public var isPeripheralConnected: Bool = false
    
    /// 현재 연결된 Peripheral (CentralManager에서 연결)
    var connectedPeripheral: CBPeripheral?
    
    /// 메세지 송신을 위한 Characteristic 객체
    var messageCharacteristic: CBCharacteristic?
    
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

// MARK: - Central관점 - CBCentralManager
extension BlueberryChatService: CBCentralManagerDelegate {
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        centralManagerState = central.state
    }
    
    public func startScan() {
        discoveredPeripheral = []
        
        if (centralManagerState == .poweredOn) {
            centralManager.scanForPeripherals(
                withServices: [ChatBleSpec.serviceUUID], // 정의된 서비스를 가진 장치만 스캔
                options: [CBCentralManagerRestoredStateScanOptionsKey: true]
            )
        }
    }
    
    public func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String : Any],
        rssi RSSI: NSNumber
    ) {
        print("⭐️ didDiscover: \(peripheral.description)")
        print("⭐️ advertisementData: \(advertisementData.description)")
        
        // 1. advertisementData에서 CBAdvertisementDataLocalNameKey를 확인합니다.
        guard let localName = advertisementData[CBAdvertisementDataLocalNameKey] as? String else { return }
        
        // 2. 스캔된 장치가 장치목록(discoveredPeripherals)에 있는지 확인합니다.(UUID로 구별)
        let duplicatedPeripheral = self.discoveredPeripheral.first(where: { $0.peripheral.identifier == peripheral.identifier })
        
        if duplicatedPeripheral == nil { // 2-1. 없다면, 장치목록에 추가합니다.
            let model = PeripheralScanInfo(
                peripheral: peripheral,
                localName: localName,
                advertisenemtData: advertisementData,
                rssi: RSSI
            )
            self.discoveredPeripheral.append(model)
            
        } else { // 2-2. 있다면, 장치목록에서 해당 장치의 정보를 업데이트합니다.
     
            duplicatedPeripheral!.update(
                localName: localName,
                advertisenemtData: advertisementData,
                rssi: RSSI
            )
        }

        // 3. RSSI를 기준으로 장치목록을 내림차순 정렬합니다.(가까운 순)
        discoveredPeripheral.sort { $0.rssi > $1.rssi }
    }
    
    public func connect(peripheral: CBPeripheral) {
        centralManager.connect(peripheral, options: nil)
    }
    
    /**
     uuid를 통해 연결할 때 사용하는 메소드
     */
    private func connect(uuid: UUID) {
        guard let p = centralManager.retrievePeripherals(withIdentifiers: [uuid]).first
        else {
            // 연결 실패
            return
        }
        
        centralManager.connect(p, options: nil)
    }
    
    public func disconnect() {
        guard let connectedPeripheral = connectedPeripheral else { return }
        
        // 연결된 Peripheral 연결 해제
        centralManager.cancelPeripheralConnection(connectedPeripheral)
        
        // 메세지 초기화
        self.messages = []
    }
    
    public func centralManager(
        _ central: CBCentralManager,
        didConnect peripheral: CBPeripheral
    ) {
        connectedPeripheral = peripheral
        isPeripheralConnected = true
        
        // 1. delegate 설정
        peripheral.delegate = self
        
        // 2. 서비스 탐색
        peripheral.discoverServices(nil)
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

// MARK: - Central관점 - CBPeripheral
extension BlueberryChatService: CBPeripheralDelegate {
    public func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverServices error: Error?
    ) {
        guard let services = peripheral.services else {
            print("Error: didDiscoverServices, service guard let binding failure")
            return
        }
        
        // 발견된 Service들의 Characteristic 탐색
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    public func peripheral(
        _ peripheral: CBPeripheral,
        didDiscoverCharacteristicsFor service: CBService,
        error: Error?
    ) {
        guard let characteristics = service.characteristics else { return }
        
        // 발견된 Characteristic의 UUID가 정의한 UUID와 동일한지 확인
        if let characteristic = characteristics.first(where: {
            $0.uuid.isEqual(ChatBleSpec.rxUUID)
        }) {
            self.messageCharacteristic = characteristic
        }
    }
    
    public func sendMessage(text: String) {
        // 1. text를 UTF8로 인코딩
        guard let data = text.data(using: .utf8) else { return }
        guard let messageCharacteristic = messageCharacteristic else { return }
        
        // 2. Characteristic에 메세지 데이터 write
        connectedPeripheral?.writeValue(data, for: messageCharacteristic, type: .withResponse)
        
        // 3. 송신한 메세지 저장
        let message = Message(text: text, received: false, timestamp: Date())
        messages.append(message)
    }
}



// MARK: - Peripheral관점 - CBPeripheralManager
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
        // 1. Service 객체 생성
        let chatService = CBMutableService(
            type: ChatBleSpec.serviceUUID,
            primary: true
        )
        
        // 2. Characteristic 객체 생성
        let rxCharacteristic = CBMutableCharacteristic(
            type: ChatBleSpec.rxUUID,
            properties: ChatBleSpec.rxProperties,
            value: nil,
            permissions: ChatBleSpec.rxPermissions
        )
        
        // 3. Service Characteristic 관계 정의
        chatService.characteristics = [rxCharacteristic]
        
        // 4. PeripheralManager에 Service 추가
        peripheralManager.add(chatService)
    }
    
    public func endAdvertising() {
        // 전체 서비스 제거
        peripheralManager.removeAllServices()
        
        // 방출 중지
        peripheralManager.stopAdvertising()
        
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
            // 1. connectedPeripheral이 존재할 때,
            guard let connectedPeripheral = connectedPeripheral else { return }
            
            // 2. connectedPeripheral의 UUID와 수신자(Central)의 UUID가 동일하다면
            guard connectedPeripheral.identifier == request.central.identifier else { return }
            
            // 3. 수신된 메세지 데이터를 저장합니다.
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
