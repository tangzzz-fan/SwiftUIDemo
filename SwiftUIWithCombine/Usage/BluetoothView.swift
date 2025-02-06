//
//  BluetoothView.swift
//  SwiftUIWithCombine
//
//  Created by Tang Tango on 2025/1/24.
//

import Combine
import CoreBluetooth
import SwiftUI

// MARK: - 蓝牙服务
class BluetoothManager: NSObject, ObservableObject {
    @Published var peripherals: [CBPeripheral] = []
    @Published var isScanning = false
    @Published var connectionState = CBManagerState.unknown
    @Published var connectedDevice: CBPeripheral?

    private var centralManager: CBCentralManager!
    private var cancellables = Set<AnyCancellable>()

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: nil, queue: .main)

        centralManager.delegate = self
    }

    func startScanning() {
        guard centralManager.state == .poweredOn else { return }
        isScanning = true
        peripherals.removeAll()
        centralManager.scanForPeripherals(withServices: nil)
    }

    func stopScanning() {
        isScanning = false
        centralManager.stopScan()
    }

    func connect(to peripheral: CBPeripheral) {
        centralManager.connect(peripheral)
    }

    func disconnect() {
        if let peripheral = connectedDevice {
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }
}

// MARK: - CBCentralManagerDelegate
extension BluetoothManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        connectionState = central.state

        if central.state == .poweredOn {
            startScanning()
        }
    }

    func centralManager(
        _ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any], rssi RSSI: NSNumber
    ) {
        if !peripherals.contains(peripheral) {
            peripherals.append(peripheral)
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectedDevice = peripheral
        stopScanning()
    }

    func centralManager(
        _ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?
    ) {
        connectedDevice = nil
        if error != nil {
            startScanning()
        }
    }
}

// MARK: - 设备列表项
struct PeripheralRow: View {
    let peripheral: CBPeripheral
    let onConnect: () -> Void

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(peripheral.name ?? "未知设备")
                    .font(.headline)
                Text(peripheral.identifier.uuidString)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button("连接") {
                onConnect()
            }
            .buttonStyle(.bordered)
        }
        .padding(.vertical, 8)
    }
}

struct BluetoothView: View {
    @StateObject private var bluetoothManager = BluetoothManager()

    var body: some View {
        List {
            Section {
                HStack {
                    Text("蓝牙状态:")
                        .font(.headline)

                    switch bluetoothManager.connectionState {
                    case .poweredOn:
                        Label("已开启", systemImage: "bluetooth")
                            .foregroundStyle(.green)
                    case .poweredOff:
                        Label("已关闭", systemImage: "bluetooth.slash")
                            .foregroundStyle(.red)
                    default:
                        Label("未知状态", systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.yellow)
                    }
                }
            }

            if bluetoothManager.connectionState == .poweredOn {
                Section {
                    if bluetoothManager.isScanning {
                        HStack {
                            ProgressView()
                            Text("正在扫描设备...")
                        }
                    }

                    ForEach(bluetoothManager.peripherals, id: \.identifier) { peripheral in
                        PeripheralRow(peripheral: peripheral) {
                            bluetoothManager.connect(to: peripheral)
                        }
                    }
                } header: {
                    Text("可用设备")
                }

                if let connectedDevice = bluetoothManager.connectedDevice {
                    Section {
                        VStack(alignment: .leading) {
                            Text(connectedDevice.name ?? "未知设备")
                                .font(.headline)
                            Text(connectedDevice.identifier.uuidString)
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Button("断开连接") {
                                bluetoothManager.disconnect()
                            }
                            .buttonStyle(.bordered)
                            .tint(.red)
                            .padding(.top)
                        }
                    } header: {
                        Text("已连接设备")
                    }
                }
            }
        }
        .navigationTitle("蓝牙连接")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if bluetoothManager.connectionState == .poweredOn {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        if bluetoothManager.isScanning {
                            bluetoothManager.stopScanning()
                        } else {
                            bluetoothManager.startScanning()
                        }
                    } label: {
                        Image(
                            systemName: bluetoothManager.isScanning
                                ? "stop.circle" : "arrow.clockwise")
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        BluetoothView()
    }
}
