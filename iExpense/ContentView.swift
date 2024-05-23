//
//  ContentView.swift
//  iExpense
//
//  Created by Leo Torres Neyra on 9/1/24.
//

import SwiftUI

struct ExpenseItem: Identifiable, Codable {
    var id = UUID()
    let name: String
    let type: String
    let amount: Double
}

@Observable
class Expenses {
    var items = [ExpenseItem]() {
        didSet {
            if let encoded = try? JSONEncoder().encode(items) {
                UserDefaults.standard.set(encoded, forKey: "Items")
            }
        }
    }

    init() {
        if let savedItems = UserDefaults.standard.data(forKey: "Items") {
            if let decodedItems = try? JSONDecoder().decode([ExpenseItem].self, from: savedItems) {
                items = decodedItems
                return
            }
        }

        items = []
    }
}

struct ContentView: View {
    @State private var expenses = Expenses()

    //@State private var showingAddExpense = false
    
    let types = ["Business", "Personal"]
    private let currencyCode = Locale.current.currency?.identifier ?? "USD"

    var body: some View {
        NavigationStack {
            List {
                ForEach (types, id: \.self) { type in
                    Section {
                        ForEach(expenses.items) { item in
                            if item.type == type {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(item.name)
                                            .font(.headline)
                                        
                                        Text(item.type)
                                    }
                                    
                                    Spacer()
                                    
                                    Text(item.amount, format: .currency(code: currencyCode))
                                        .foregroundStyle(item.amount <= 5 ? .green : item.amount <= 10 ? .blue : item.amount <= 100 ? .orange : .red)
                                }
                            }
                        }
                    }header: {
                        Text(type.uppercased())
                    }
                }
                .onDelete(perform: removeItems)
            }
            .navigationTitle("iExpense")
            .toolbar {
                /** Para mostrar la ventana de agregar gastos como una hoja */
                // Button("Add Expense", systemImage: "plus") {
                //showingAddExpense = true
                //}
                
                /** Para agregar gastos como una nueva ventana */
                NavigationLink(destination: AddView(expenses: expenses)) {
                    Image(systemName: "plus")
                }
                
                EditButton()
            }
            /** Para mostrar la ventana de agregar gastos como una hoja */
            //.sheet(isPresented: $showingAddExpense) {
            //    AddView(expenses: expenses)
            //}
        }
        
    }

    func removeItems(at offsets: IndexSet) {
        expenses.items.remove(atOffsets: offsets)
    }
}

#Preview {
    ContentView()
}

