//
//  ContentView.swift
//  DataCollectorForAppleWatch Watch App
//
//  Created by Jaehyeok Lim on 2022/10/31.
//

import SwiftUI
import CoreMotion
import CoreLocation

let motionManager = CMMotionManager()
let altimeterManger = CMAltimeter()
//var locationManager = CLLocationManager()

struct ContentView: View {
    
    var body: some View {
        VStack {
            Button("csvFolder", action: createCSV)

        }
        .padding()
    }
}

func createCSV() {
    let fileManager = FileManager.default
    
    let folderName = "CSVFolder"
    
    let documentUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    let directoryUrl = documentUrl.appendingPathComponent(folderName)

    do {
        try fileManager.createDirectory(atPath: directoryUrl.path, withIntermediateDirectories: true, attributes: nil)
    }
    catch let error as NSError {
        print("폴더 생성 에러: \(error)")
    }
}

func writeCSV(sensorData: String, caseType: String, index: Int) {
    let fileManager = FileManager.default
    
    let folderName = "CSVFolder"
    let csvFileName = "\(caseType)_\(index).csv"
    
    let documentUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    let directoryUrl = documentUrl.appendingPathComponent(folderName)
    let fileUrl = directoryUrl.appendingPathComponent(csvFileName)
    
    let fileData = sensorData.data(using: .utf8)
        
        do {
            try fileData?.write(to: fileUrl)
            
            print("Writing CSV to: \(fileUrl.path)")
        }
        catch let error as NSError {
            print("CSV파일 생성 에러: \(error)")
        }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
