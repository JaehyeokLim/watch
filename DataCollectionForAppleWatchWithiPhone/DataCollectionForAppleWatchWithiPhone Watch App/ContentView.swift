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
var accArray: [String] = []
var rotArray: [String] = []
var preArray: [String] = []
var locArray: [CLLocation] = []

var createBool: Bool = false

let sensorNameArray: [String] = ["wAcc", "wGyr", "wPre"]

var accList: String = ""
var rotList: String = ""
var preList: String = ""

var count: Int = 1

struct ContentView: View {
    @State var currentDate = Date()
    @State var secondsLeft: Int = 10
    @State var secondsSave: Int = 10
    @State var minutes: Int = 0
    @State var seconds: Int = 0
    @StateObject var watchLocationManager = WatchLocManager()
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            
            Text("\(minutes):\(seconds)")
                .onReceive(timer) { _ in
                    secondsLeft -= 1

                    //남은 분
                    minutes = secondsLeft / 60
                    //그러고도 남은 초
                    seconds = secondsLeft % 60
                    
                    if secondsLeft == 0 {
                        WatchLocManager().aaa()
                        secondsLeft = secondsSave
                    }
                }
                
            Text("")
            
            Text("Not start the sensing yet")
                .fontWeight(.bold)
                .font(.system(size: 14))
            
            Text("please wait..")
                .fontWeight(.light)
                .font(.system(size: 14))
            
            Text("checking the network")
                .fontWeight(.light)
                .font(.system(size: 14))
            
//            Button("hello", action: watchLocationManager.motionManagerInit() )
            
            Text("Hello World")
            .onAppear {
                watchLocationManager.motionManagerInit()
            }
            
            Button("Request location") { watchLocationManager.requestAuthorization() }
                        .onAppear {
                watchLocationManager.setupLocationManager()
            }
            
//            Button("csvFolder", action: watchLocationManager.createCSV)
//            Button("csvFiie", action: watchLocationManager.writeCSV)

        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

class WatchLocManager: NSObject, ObservableObject {

    private var locationManager = CLLocationManager()
    
//    func timerFunction() {
//        Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (t) in
//            //남은 시간(초)에서 1초 빼기
//            secondsLeft -= 1
//
//            //남은 분
//            minutes = secondsLeft / 60
//            //그러고도 남은 초
//            seconds = secondsLeft % 60
//
//            //남은 시간(초)가 0보다 크면
//
//        })
//    }
    
    func startFunction() {
        motionManagerInit()
//        Timer.scheduledTimer(timeInterval: 900, target: self, selector: #selector(aaa), userInfo: nil, repeats: true)
        print("start")
    }
    
    func setupLocationManager() {
//        self.createCSV()
//        self.timerFunction()
        self.locationManager.delegate = self
        self.locationManager.allowsBackgroundLocationUpdates = true
        self.locationManager.activityType = .otherNavigation
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
//        self.locationManager.distanceFilter = 20.0
        self.locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            print("위치 서비스 On 상태")
            locationManager.startUpdatingLocation() //위치 정보 받아오기 시작
//            print(locationManager.location?.coordinate as Any)
        } else {
            print("위치 서비스 Off 상태")
        }
    }
    
    func requestAuthorization() {
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    func motionManagerInit() {
        print("start")
        
        motionManager.accelerometerUpdateInterval = 1 / 20
        motionManager.gyroUpdateInterval = 1 / 20
        
        if let currentValue = OperationQueue.current {
            motionManager.startAccelerometerUpdates(to: currentValue, withHandler: {
                    (accelerometerData: CMAccelerometerData!, error: Error!) -> Void in
                    self.outputAccelerationData(accelerometerData.acceleration)
                    if (error != nil) {
                        print("\(error!)")
                    }
                })

            motionManager.startGyroUpdates(to: currentValue, withHandler: {
                (gyroData: CMGyroData!, error: Error!) -> Void in
                self.outputRotationData(gyroData.rotationRate)
                if (error != nil) {
                    print("\(error!)")
                }
            })
            
            if CMAltimeter.isRelativeAltitudeAvailable() {
                altimeterManger.startRelativeAltitudeUpdates(to: currentValue, withHandler: {
                    (altimeterData: CMAltitudeData!, error: Error!) -> Void in
                    self.outputAlititudeData(altimeterData)
                    if (error != nil) {
                        print("\(error!)")
                    }
                })
            }
        }
    }

    func outputAccelerationData(_ acceleration: CMAcceleration) {
        let currentDate = Date()
        
//        print("\(acceleration.x)")
        if accArray.count < 45 {
            accArray.append(String(format: "%.3f", acceleration.x))
            accArray.append(String(format: "%.3f", acceleration.y))
            accArray.append(String(format: "%.3f", acceleration.z))

        } else {
        
            sendToData(array: accArray, time: currentDate, caseType: "mAcc")
            accArray.removeAll()
        }
    }

    func outputRotationData(_ rotation: CMRotationRate) {
        let currentDate = Date()

        if rotArray.count < 45 {
            rotArray.append(String(format: "%.3f", rotation.x))
            rotArray.append(String(format: "%.3f", rotation.y))
            rotArray.append(String(format: "%.3f", rotation.z))
            
        } else {
        
            sendToData(array: rotArray, time: currentDate, caseType: "mGyr")
            rotArray.removeAll()
        }    }

    func outputAlititudeData(_ altitude: CMAltitudeData) {
        let currentDate = Date()
            
        preArray.append(String(format: "%.3f", Double(truncating: altitude.pressure) * 10))

        if preArray.count >= 1 {
            
            sendToData(array: preArray, time: currentDate, caseType: "mPre")
            preArray.removeAll()
        }
    }
    
    func sendToData(array: [String], time: Date, caseType: String) {
        
        if caseType == "mAcc" {
            
            accList += String(format: "%.0f", time.timeIntervalSince1970)

            for i in 0..<array.count {
                accList += "," + array[i]
            }
            
            accList += "\n"
            
        } else if caseType == "mGyr" {
            
            rotList += String(format: "%.0f", time.timeIntervalSince1970)

            for i in 0..<array.count {
                rotList += "," + array[i]
            }
            
            rotList += "\n"
            
        } else if caseType == "mPre" {
            
            preList += String(format: "%.0f", time.timeIntervalSince1970)

            preList += "," + array[0]

            preList += "\n"
        }
        
//        print("\(preList))")
    }
    
    @objc func aaa() {
        createCSV()
        writeCSV(sensorData: accList, caseType: "wAcc", index: count)
        writeCSV(sensorData: rotList, caseType: "wGyr", index: count)
        writeCSV(sensorData: preList, caseType: "wPre", index: count)
        
        readFile(fileNumber: count)
        
        print(count)
        count += 1
//        updateCountNumberLabel.text = String(count)

        accList = ""; rotList = ""; preList = ""
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
    
    func csvDataPostToMobius(csvData: String, conName: String) {
        let semaphore = DispatchSemaphore (value: 0)

        let parameters = "{\n    \"m2m:cin\": {\n        \"con\": \"\(csvData)\"\n    }\n}"
        let postData = parameters.data(using: .utf8)

        var request = URLRequest(url: URL(string: "http://114.71.220.59:7579/Mobius/S997/watch/\(conName)")!,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("12345", forHTTPHeaderField: "X-M2M-RI")
        request.addValue("SIWLTfduOpL", forHTTPHeaderField: "X-M2M-Origin")
        request.addValue("application/vnd.onem2m-res+json; ty=4", forHTTPHeaderField: "Content-Type")

        request.httpMethod = "POST"
        request.httpBody = postData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard data != nil else {
              print(String(describing: error))
              semaphore.signal()
              return
          }
//            print(String(data: data, encoding: .utf8)!)
            print("\(conName) Data is served.")
            semaphore.signal()
        }

        task.resume()
        semaphore.wait()
    }
    
    func readFile(fileNumber: Int) {
        
        for fileName in sensorNameArray {
            let fileManager = FileManager.default
            
            let folderName = "CSVFolder"
            let csvFileName = "\(fileName)_\(fileNumber).csv"
            
            let documentUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let directoryUrl = documentUrl.appendingPathComponent(folderName)
            let fileUrl = directoryUrl.appendingPathComponent(csvFileName)
            
            do {
                let dataFromPath: Data = try Data(contentsOf: fileUrl) // URL을 불러와서 Data타입으로 초기화
                let text: String = String(data: dataFromPath, encoding: .utf8) ?? "문서없음" // Data to String
                let data = text.replacingOccurrences(of: "\n", with: "")
                csvDataPostToMobius(csvData: data, conName: fileName)
//                print(data)
                
            } catch let e {
                print(e.localizedDescription)
            }
        }
    }
}

extension WatchLocManager: CLLocationManagerDelegate {

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print("⌚️ locationManagerDidChangeAuthorization: \(manager.authorizationStatus.rawValue)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        print(locations)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        print(error)
    }
}
