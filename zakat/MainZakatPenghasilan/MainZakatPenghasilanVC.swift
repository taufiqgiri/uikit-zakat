//
//  MainZakatPenghasilanVC.swift
//  zakat
//
//  Created by Taufiq Ichwanusofa on 29/04/22.
//

import UIKit
import CoreData

class MainZakatPenghasilanVC: UIViewController {
    @IBOutlet weak var formView: UIView!
    @IBOutlet weak var controlPeriod: UISegmentedControl!
    @IBOutlet weak var tfMainIncome: UITextField!
    @IBOutlet weak var tfAdditionalIncome: UITextField!
    @IBOutlet weak var tfMainOutcome: UITextField!
    @IBOutlet weak var lblHargaEmas: UILabel!
    @IBOutlet weak var titleIncomeZakat: UILabel!
    @IBOutlet weak var titleCalculator: UILabel!
    @IBOutlet weak var lblMainIncome: UILabel!
    @IBOutlet weak var lblAdditionalIncome: UILabel!
    @IBOutlet weak var lblMainOutcome: UILabel!
    @IBOutlet weak var lblNisabZakat: UILabel!
    @IBOutlet weak var lblGoldPrice: UILabel!
    @IBOutlet weak var lblPreferredCalculate: UILabel!
    @IBOutlet weak var btnHitung: CustomButton!
    
    var currentGoldPrice: Double = 26568750.000000004
    var zakatFee: Int = 0
    var labelHargaEmas: String = "Current gold price is ..."
    var goldPricePerGram: Int = 0
    var period: String = "Bulanan"
    var corePrice: [NSManagedObject] = []
    var currentDate: String?
    
    override func viewWillAppear(_ animated: Bool) {
        let url = "https://metals-api.com/api/latest?access_key=mbq6pwis89i70cfb6nhins02ceysrjo8rcg8ao0a8sr852aaz1mfg0ok06hf&base=IDR&symbols=XAU%2CXAG%2CXPD%2CXPT%2CXRH"
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        currentDate = dateFormatter.string(from: date)
        
//        get data gold price from core data
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Price")
        
        do {
            corePrice = try managedContext.fetch(fetchRequest)
            if corePrice.count > 0 && (corePrice[0].value(forKey: "fetchingDate") as! String == self.currentDate!) {
                if let tempPrice = corePrice[0].value(forKey: "goldPrice") {
                    let intTempPrice = tempPrice as! Int
                    self.labelHargaEmas = ">> Current gold price is Rp. \(intTempPrice.formattedWithSeparator)"
                    self.goldPricePerGram = intTempPrice
                } else {
                    self.labelHargaEmas = ">> Current gold price is ..."
                }
                
                return DispatchQueue.main.asyncAfter(deadline: .now()) {
                    self.viewDidLoad()
                }
            } else {
                getDataMetalPrice(from: url)
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        setupView()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MainZakatPenghasilanVC.backgroundTap))
        self.view.addGestureRecognizer(tapGestureRecognizer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(MainZakatPenghasilanVC.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        tfMainIncome.addTarget(self, action: #selector(myTextFieldDidChange), for: .editingChanged)
        tfAdditionalIncome.addTarget(self, action: #selector(myTextFieldDidChange), for: .editingChanged)
        tfMainOutcome.addTarget(self, action: #selector(myTextFieldDidChange), for: .editingChanged)
        
        tfMainIncome.accessibilityLabel = "Input your main income"
        tfAdditionalIncome.accessibilityLabel = "Input your additional income"
        tfMainOutcome.accessibilityLabel = "Input your main outcome"
                
        lblHargaEmas.text = labelHargaEmas
    }
    
//    get data gold price from API
    private func getDataMetalPrice(from url: String) {
        print("~ get from endpoint")
        URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: { data, response, error in
            guard let data = data, error == nil else {
                print("~ failed get data")
                return
            }
            
            var result: MetalPriceResponse?
            do {
                result = try JSONDecoder().decode(MetalPriceResponse.self, from: data)
            } catch {
                print("~ error \(error.localizedDescription)")
                print(String(describing: error))
            }
            
            guard let json = result else {
                return
            }
            
            let currentCoreGoldPrice = json.rates.XAU
            self.currentGoldPrice = currentCoreGoldPrice
            let goldPrice = Int(round(currentCoreGoldPrice / 28.3495))
            self.labelHargaEmas = ">> Current gold price is Rp. \(goldPrice.formattedWithSeparator)"
            self.goldPricePerGram = goldPrice
            
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                self.viewDidLoad()
                self.saveToCoreData(currentPrice: round(currentCoreGoldPrice / 28.3495))
            }
        }).resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ResultZakatPenghasilanVC
        destinationVC.zakatFee = zakatFee
    }
    
    @IBAction func indexChanged(_ sender: Any) {
        switch controlPeriod.selectedSegmentIndex {
        case 0:
            period = "Bulanan"
        case 1:
            period = "Tahunan"
        default:
            break
        }
    }
    
    func setupView() {
        formView.layer.cornerRadius = 30
        controlPeriod.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: UIControl.State.selected)
        controlPeriod.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: UIControl.State.normal)
        tfMainIncome.keyboardType = .asciiCapableNumberPad
        tfAdditionalIncome.keyboardType = .asciiCapableNumberPad
        tfMainOutcome.keyboardType = .asciiCapableNumberPad
        btnHitung.layer.cornerRadius = 30
        
//        ====== Start Styling Accessibility ======
        guard let customTitleFont = UIFont(name: "Futura", size: 40) else {
            fatalError("""
                Failed to load the "CustomFont-Light" font.
                Make sure the font file is included in the project and the font name is spelled correctly.
            """)
        }
        
        guard let customBodyFont = UIFont(name: "Chalkboard SE", size: 13) else {
            fatalError("""
                Failed to load the "CustomFont-Light" font.
                Make sure the font file is included in the project and the font name is spelled correctly.
            """)
        }
        
        guard let customLabelFont = UIFont(name: "Chalkboard SE", size: 14) else {
            fatalError("""
                Failed to load the "CustomFont-Light" font.
                Make sure the font file is included in the project and the font name is spelled correctly.
            """)
        }
        
        titleIncomeZakat.font = UIFontMetrics(forTextStyle: .largeTitle).scaledFont(for: customTitleFont)
        titleCalculator.font = UIFontMetrics(forTextStyle: .largeTitle).scaledFont(for: customTitleFont)
        lblMainIncome.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: customLabelFont)
        lblAdditionalIncome.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: customLabelFont)
        lblMainOutcome.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: customLabelFont)
        btnHitung.titleLabel!.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: customLabelFont)
        lblNisabZakat.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: customBodyFont)
        lblGoldPrice.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: customBodyFont)
        lblPreferredCalculate.font = UIFontMetrics(forTextStyle: .caption1).scaledFont(for: customBodyFont)
        
        titleIncomeZakat.adjustsFontForContentSizeCategory = true
        titleCalculator.adjustsFontForContentSizeCategory = true
        lblMainIncome.adjustsFontForContentSizeCategory = true
        lblAdditionalIncome.adjustsFontForContentSizeCategory = true
        lblMainOutcome.adjustsFontForContentSizeCategory = true
        btnHitung.titleLabel!.adjustsFontForContentSizeCategory = true
        lblNisabZakat.adjustsFontForContentSizeCategory = true
        lblGoldPrice.adjustsFontForContentSizeCategory = true
        lblPreferredCalculate.adjustsFontForContentSizeCategory = true
//        ====== End Styling Accessibility ======
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        self.view.frame.origin.y = 30 - keyboardSize.height
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    @objc func backgroundTap(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
        self.view.frame.origin.y = 0
    }
    
    @objc func myTextFieldDidChange(_ textField: UITextField) {
        if let amountString = textField.text?.currencyFormatting() {
            textField.text = amountString
        }
    }
        
    @IBAction func calculate(_ sender: Any) {        
        let mainIncome = Int(tfMainIncome.text != "" ? tfMainIncome.text!.replacingOccurrences(of: ".", with: "") : "0")
        let mainOutcome = Int(tfMainOutcome.text != "" ? tfMainOutcome.text!.replacingOccurrences(of: ".", with: "") : "0")
        let additionalIncome = Int(tfAdditionalIncome.text != "" ? tfAdditionalIncome.text!.replacingOccurrences(of: ".", with: "") : "0")
        let nettoIncome = (mainIncome ?? 0) + (additionalIncome ?? 0) - (mainOutcome ?? 0)
        
        if self.period == "Bulanan" {
            let nasabZakat = (self.goldPricePerGram * 85) / 12
            print("~ netto income : \(nettoIncome)")
            print("~ nasab : \(nasabZakat)")
            if nettoIncome > nasabZakat {
                zakatFee = Int(Double(nettoIncome) * (0.025))
            } else {
                zakatFee = 0
            }
        } else {
            let nasabZakat = self.goldPricePerGram * 85
            if nettoIncome > nasabZakat {
                zakatFee = Int(Double(nettoIncome) * (0.025))
            } else {
                zakatFee = 0
            }
        }
        
        tfMainIncome.text = ""
        tfMainOutcome.text = ""
        tfAdditionalIncome.text = ""
        
        performSegue(withIdentifier: "showZakatFee", sender: self)
    }
    
    func saveToCoreData(currentPrice: Double) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        for data in corePrice {
            managedContext.delete(data)
        }
        let entity = NSEntityDescription.entity(forEntityName: "Price", in: managedContext)
        let price = NSManagedObject(entity: entity!, insertInto: managedContext)
        price.setValue(currentPrice, forKey: "goldPrice")
        price.setValue(currentDate, forKey: "fetchingDate")
        
        do {
            try managedContext.save()
            corePrice = [price]
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}
