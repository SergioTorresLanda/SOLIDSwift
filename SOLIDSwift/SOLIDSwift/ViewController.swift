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






