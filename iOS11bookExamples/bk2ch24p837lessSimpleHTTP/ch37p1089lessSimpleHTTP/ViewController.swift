

import UIKit

class ViewController: UIViewController, URLSessionDownloadDelegate {

    @IBOutlet var iv : UIImageView!
    var task : URLSessionTask!
    
    let which = 0 // 0 or 1
    
    lazy var session : URLSession = {
        let config = URLSessionConfiguration.ephemeral
        config.allowsCellularAccess = false
        let session = URLSession(configuration: config, delegate: self, delegateQueue: .main)
        return session
    }()

    var progress : Progress!
    
    @IBAction func doElaborateHTTP (_ sender: Any!) {
        if self.task != nil {
            return
        }
        self.iv.image = nil
        let s = "https://www.apeth.net/matt/images/phoenixnewest.jpg"
        let url = URL(string:s)!
        switch which {
        case 0:
            let req = URLRequest(url:url)
            let task = self.session.downloadTask(with:req)
            self.progress = task.progress // *
            self.task = task
            task.resume()

        case 1:
            let req = NSMutableURLRequest(url:url)
            URLProtocol.setProperty("howdy", forKey:"greeting", in:req)
            let task = self.session.downloadTask(with:req as URLRequest)
            self.task = task
            task.resume()

        default:break
        }

    }
        
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten writ: Int64, totalBytesExpectedToWrite exp: Int64) {
        print("downloaded \(100*writ/exp)%")
        // but new in iOS 11 there's another way to get that information:
        print(self.progress.fractionCompleted)
        // observe that that works only if we have retains the Progress object from the outset
        // we cannot, for example, ask for downloadTask.progress.fractionComplete _now_
        // we'll get the wrong answer
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        // unused in this example
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        self.task = nil
        print("completed: error: \(error as Any)")
    }
    
    // this is the only required URLSessionDownloadDelegate method

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo fileURL: URL) {
        if which == 1 {
            let req = downloadTask.originalRequest!
            if let greeting = URLProtocol.property(forKey:"greeting", in:req) as? String {
                print(greeting)
            }
        }
        self.task = nil
//        let response = downloadTask.response as! HTTPURLResponse
//        let stat = response.statusCode
//        print("status \(stat)")
//        if stat != 200 {
//            return
//        }
        if let d = try? Data(contentsOf:fileURL) {
            let im = UIImage(data:d)
            DispatchQueue.main.async {
                self.iv.image = im
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.session.finishTasksAndInvalidate()
    }
    
    deinit {
        print("farewell")
    }
    
}
