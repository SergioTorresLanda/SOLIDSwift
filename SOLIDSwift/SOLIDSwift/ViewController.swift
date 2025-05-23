//
//  ViewController.swift
//  SOLIDSwift
//
//  Created by Sergio Torres Landa González on 19/05/25.
//  SOLID = 5 code arquitechture principles, when applied together creates a system more easy to mantain and extend or scale over time:
//1. Single Responsability
//2. Open-Closed
//3. Liskov-Substitution
//4. Interface segregation
//5. Dependency inversion

import UIKit

class ViewController: UIViewController {

    let prods: [Product] = [
        .init(price: 9.99),
        .init(price: 9.88),
        .init(price: 7.77)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //1. Single resp.
        let invoice = Invoice(products: prods, discountPercentage: 20)
        invoice.printInvoice()
        invoice.saveInvoice()
     
    }
    
}

//1. SINGLE RESPONSABILITY (A class should have only one responsability)

struct Product {
    let price: Double
}

struct Invoice {
    var products: [Product]
    let id = NSUUID().uuidString
    var discountPercentage: Double = 0
    
    var total:Double{
        let total = products.map({$0.price}).reduce(0, {$0 + $1})
        let disccountedAmount = total * (discountPercentage/100)
        return total - disccountedAmount
    }// only responsability !
    
    func printInvoice(){
        //print("Invoiceid:" + String(invoice.id))
        //print("Total cost:" + String(invoice.total)) // X move logics to another class !!
        let printer = InvoicePrinter(invoice: self)
        printer.printInvoice()
    }
    
    func saveInvoice(){ // X move logics to another class !!
        let service = InvoicePersistence2(invoice: self, persistence: CoreDataP())
        service.save() //Refactor like this to avoid creating a lot of instances of classes outside the main class
    }
}//Multiple responsabilities !!!

//Create more classes to take other resposabilities..::
struct InvoicePrinter {
    let invoice:Invoice
    func printInvoice() {
        print("Invoiceid:" + String(invoice.id))
        print("Total cost:" + String(invoice.total))
    }
}
struct InvoicePersistence {
    let invoice:Invoice
    func saveInvoice() {
        //logics to save on DB
    }
}

//2. OPEN-CLOSED
// Software entities (classes, modules, functions, etc.) should be open for extension but close for modification.
// i.e: we should add functionality (extension) without touching the existing code of an obj.

//F EX: dont modify Int class intself.. else, create an extesion !
extension Int {
    func squared() -> Int {
        return self*self
    }
}
//For ex. If we want to add functionality to InvoicePersistence:

struct InvoicePersistence2 {
    let invoice:Invoice
    /*
    func saveInvoiceToFirestore() {
        //logics to save on DB
    }
    func saveInvoiceToCoreData() {
        //logics to save on Core
    }*/ //inted of :
    let persistence: InvoicePersistable
    func save(){
        persistence.save(invoice:invoice)
    }
}
//Create protocol
protocol InvoicePersistable{
    func save(invoice: Invoice)
}
//Create structs that conform and implement method as they want to
struct CoreDataP :InvoicePersistable{
    func save(invoice: Invoice) {
        print("saved to Core data")
    }
}
struct FirebaseP :InvoicePersistable{
    func save(invoice: Invoice) {
        print("saved to firestore")
    }
}

//3. LISKOV-SUBSTITUTION
//Derived or child classes/structs should be substitutable for their base parent classes
enum APIError: Error {
    case invalidURL
    case invalidUResp
    case invalidStatus
}

struct mockUserService{
    func fetchUser() async throws{
        do{
            throw APIError.invalidUResp // this is easily substitutable for URLError(.badURL) or any other err which conforms to Error parent class.
        }catch{
            print(error)
        }
    }
}
//Functions that use pointers of references to base classes must be able to use objects of derived classes without knowing it. (inject portocol obj as param) ex: 
protocol Polygon {
    var area: Double {get}
}

class Rectangle: Polygon{
    private let width: Double
    private let lenght: Double
    init(width: Double, lenght: Double) {
        self.width = width
        self.lenght = lenght
    }
    var area : Double {
        return width*lenght
    }
}
class Square: Polygon{
    private let side: Double
    init(side: Double) {
        self.side = side
    }
    var area : Double {
        return pow(side,2)
    }
}

func printArea(polygon:Polygon){
    print(polygon.area)
}



//4. NTERFACE-SEGREGATION (Atomic Protocols)
//Do not force any client to implement an interface which is irrelevant to them.

protocol GestureProtocol{
    func didTap()
    func didDoubleTap()
    func didLongPress()
}

struct SuperButton:GestureProtocol{
    func didTap() {
    }
    
    func didDoubleTap() {
    }
    
    func didLongPress() {
    }
}

struct DoubleTapButton:GestureProtocol{
    func didTap() {}//not used
    func didDoubleTap() {
        //do something
    }
    func didLongPress() {}//not used
} //This struct does not comply with the principle since it implements several methods which are irrelevant to them. So segragate the protocol !! Now each struct can conform only to the protocols needed !

    protocol TapProtocol{
        func didTap()
    }
    protocol DoubleProtocol{
        func didDoubleTap()
    }
    protocol LongProtocol{
        func didLongPress()
    }

//5. DEPENDENCY INVERSION
//High level modules should not depend on low level modules. but on abstractions.
//If a HL module imports any LL module then the code becomes tightly couped
//we want the code to be loosely coped
//Changes in one class could breake another class.

struct DebitCardPayment {
    func execute(amount:Double){
        print("Debit card payment success")
    }
}
struct StripePayment : PaymentMethod{ //conform to protocol
    func execute(amount:Double){
        print("Stripe card payment success")
    }
}
struct ApplePayPayment {
    func execute(amount:Double){
        print("ApplePay card payment success")
    }
}

struct Payment{
    var debitCardPayment: DebitCardPayment?
    var stripePayment: StripePayment?
    var applePayPayment: ApplePayPayment?
}

let paymentMethod = DebitCardPayment()
let payment = Payment(debitCardPayment: paymentMethod, // This does not follow DIP
                      stripePayment: nil,
                      applePayPayment: nil)
// payment.debitCardPayment?.execute(amount: 100) tightly couped (I dont exactly know which payment method is not nil)
// payment.stripePayment?.execute(amount: 100) no way to knowing this PM is nil

//Let's depend on absraction !

protocol PaymentMethod {
    func execute(amount: Double)
}

struct PaymentGood{
    var payment: PaymentMethod //not a optional abstraction!!!
    
    func makePayment(amount: Double){
        payment.execute(amount: amount)
    }
}

let stripe = StripePayment() //create the actual instance
let paymentGood = PaymentGood(payment: stripe) //inject to abstraction

// paymentGood.makePayment(amount: 200) //cleaner !!


















