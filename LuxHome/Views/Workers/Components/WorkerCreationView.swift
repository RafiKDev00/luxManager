//
//  WorkerCreationView.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/21/25.
//

import SwiftUI
import Contacts
import ContactsUI

struct WorkerCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(LuxHomeModel.self) private var model
    var onSave: ((LuxWorker) -> Void)? = nil

    @State private var workerName: String = ""
    @State private var company: String = ""
    @State private var phone: String = ""
    @State private var email: String = ""
    @State private var selectedSpecialization: String = "Cleaner"
    @State private var servicesText: String = ""
    @State private var selectedScheduleType: ScheduleType = .oneTime
    @State private var showingContactPicker = false
    @State private var validationError: String?
    @State private var contactAccessError: String?

    let specializations = ["Cleaner", "Gardener", "Pool Service", "HVAC Tech", "Plumber", "Electrician", "Other"]

    var body: some View {
        NavigationStack {
            Form {
                contactImportSection
                basicInfoSection
                specializationSection
                servicesSection
                scheduleSection
            }
            .safeAreaBar(edge: .top, spacing: 0) {
                topBar
            }
            .sheet(isPresented: $showingContactPicker) {
                ContactPickerView { contact in
                    importContact(contact)
                }
            }
            .alert("Invalid Entry", isPresented: .constant(validationError != nil), actions: {
                Button("OK", role: .cancel) {
                    validationError = nil
                }
            }, message: {
                if let validationError {
                    Text(validationError)
                }
            })
        }
        .scrollDismissesKeyboard(.interactively)
        .alert("Contacts Access", isPresented: .constant(contactAccessError != nil), actions: {
            Button("OK", role: .cancel) {
                contactAccessError = nil
            }
        }, message: {
            if let contactAccessError {
                Text(contactAccessError)
            }
        })
    }

    private var contactImportSection: some View {
        Section {
            Button {
                requestContactsAccess()
            } label: {
                HStack {
                    Image(systemName: "person.crop.circle.badge.plus")
                        .foregroundStyle(.orange)
                    Text("Import from Contacts")
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            Text("Quick Import")
        }
    }

    private var basicInfoSection: some View {
        Section {
            TextField("Full Name", text: $workerName)
                .tint(.orange)
                .font(.headline)
            TextField("Company", text: $company)
                .tint(.orange)
            TextField("Phone", text: $phone)
                .keyboardType(.phonePad)
                .tint(.orange)
            TextField("Email (Optional)", text: $email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .tint(.orange)
        } header: {
            Text("Basic Information")
        }
    }

    private var specializationSection: some View {
        Section {
            Picker("Specialization", selection: $selectedSpecialization) {
                ForEach(specializations, id: \.self) { spec in
                    Text(spec).tag(spec)
                }
            }
            .tint(.orange)
        } header: {
            Text("Specialization")
        }
    }

    private var servicesSection: some View {
        Section {
            TextField("Enter services (comma separated)", text: $servicesText, axis: .vertical)
                .lineLimit(2...6)
        } header: {
            Text("Services Provided")
        } footer: {
            Text("Example: Interior Cleaning, Deep Clean, Window Washing")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var scheduleSection: some View {
        Section {
            Picker("Schedule Type", selection: $selectedScheduleType) {
                ForEach(ScheduleType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.menu)
            .tint(.orange)
        } header: {
            Text("Schedule")
        }
    }

    private var topBar: some View {
        HStack {
            closeButton
            Spacer()
            titleText
            Spacer()
            saveButton
        }
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(Color.clear)
    }

    private var closeButton: some View {
        Button {
            print("[WorkerCreation] Close button tapped")
            dismiss()
        } label: {
            Image(systemName: "xmark")
        }
        .buttonStyle(IconButtonStyle(type: .close))
        .padding(.leading, 16)
    }

    private var titleText: some View {
        Text("New Worker")
            .font(.system(size: 24, weight: .bold))
    }

    private var saveButton: some View {
        Button {
            saveWorker()
        } label: {
            Image(systemName: "checkmark")
        }
        .buttonStyle(IconButtonStyle(type: .check))
        .disabled(workerName.isEmpty || phone.isEmpty)
        .opacity(workerName.isEmpty || phone.isEmpty ? 0.8 : 1.0)
        .padding(.trailing, 16)
    }

    private func saveWorker() {
        guard isValidPhone(phone) else {
            validationError = "Please enter a valid phone number."
            return
        }
        if !email.isEmpty && !isValidEmail(email) {
            validationError = "Please enter a valid email address."
            return
        }

        let services = servicesText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        let worker = model.createWorker(
            name: workerName,
            company: company.isEmpty ? " " : company,
            phone: phone,
            email: email.isEmpty ? nil : email,
            specialization: selectedSpecialization,
            serviceTypes: services,
            scheduleType: selectedScheduleType
        )
        onSave?(worker)
        dismiss()
    }

    private func importContact(_ contact: CNContact) {
        print("[WorkerCreation] Importing contact: \(contact.givenName) \(contact.familyName)")
        workerName = "\(contact.givenName) \(contact.familyName)".trimmingCharacters(in: .whitespaces)

        if let organization = contact.organizationName.isEmpty ? nil : contact.organizationName {
            company = organization
        }

        if let phoneNumber = contact.phoneNumbers.first {
            phone = phoneNumber.value.stringValue
        }

        if let emailAddress = contact.emailAddresses.first {
            email = emailAddress.value as String
        }

        showingContactPicker = true //NOTE THAT THIS WORKED BUT POTENTIAL ERROR POINT. OTHERWISE WAS TEARING EVERYETHING DOWN THO
    }

    private func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES[c] %@", pattern).evaluate(with: email)
    }

    private func isValidPhone(_ phone: String) -> Bool {
        let trimmed = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        let pattern = #"^[+0-9()\-\s]{7,}$"#
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: trimmed)
    }

    private func requestContactsAccess() {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        switch status {
        case .authorized:
            showingContactPicker = true
        case .notDetermined:
            CNContactStore().requestAccess(for: .contacts) { granted, _ in
                DispatchQueue.main.async {
                    if granted {
                        showingContactPicker = true
                    } else {
                        contactAccessError = "Please enable Contacts access in Settings to import."
                    }
                }
            }
        default:
            contactAccessError = "Please enable Contacts access in Settings to import."
        }
    }
}

struct ContactPickerView: UIViewControllerRepresentable {
    let onSelect: (CNContact) -> Void

    func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let picker = CNContactPickerViewController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onSelect: onSelect)
    }

    class Coordinator: NSObject, CNContactPickerDelegate {
        let onSelect: (CNContact) -> Void

        init(onSelect: @escaping (CNContact) -> Void) {
            self.onSelect = onSelect
        }

        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            onSelect(contact)
        }
    }
}

#Preview {
    @Previewable @State var showingSheet = true

    Color.clear
        .sheet(isPresented: $showingSheet) {
            WorkerCreationView()
                .environment(LuxHomeModel.shared)
        }
}
