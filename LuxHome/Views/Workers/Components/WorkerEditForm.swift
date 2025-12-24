//
//  WorkerEditForm.swift
//  LuxHome
//
//  Created by RJ Kigner on 12/24/25.
//

import SwiftUI

struct WorkerEditForm: View {
    @Binding var name: String
    @Binding var company: String
    @Binding var phone: String
    @Binding var email: String
    @Binding var specialization: String
    @Binding var serviceTags: [String]
    @Binding var newServiceEntry: String
    @Binding var schedule: ScheduleType

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            contactSection
            servicesSection
            scheduleSection
        }
    }

    private var contactSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Contact")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.primary)

            groupedFieldStack {
                clearableField("Name", text: $name)
                Divider().padding(.leading, 12)
                clearableField("Company", text: $company)
                Divider().padding(.leading, 12)
                clearableField("Phone", text: $phone, keyboard: .phonePad)
                Divider().padding(.leading, 12)
                clearableField("Email", text: $email, keyboard: .emailAddress)
                Divider().padding(.leading, 12)
                clearableField("Specialization", text: $specialization, autocap: .words)
            }
        }
    }

    private var servicesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Services Provided")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.primary)

            FlowLayout(spacing: 8) {
                ForEach(serviceTags, id: \.self) { service in
                    HStack(spacing: 6) {
                        Image(systemName: "xmark")
                            .font(.caption2.bold())
                            .foregroundStyle(.white)
                            .padding(.leading, 6)
                            .onTapGesture {
                                removeService(service)
                            }
                        Text(service)
                            .font(.subheadline)
                            .foregroundStyle(.white)
                            .padding(.vertical, 6)
                            .padding(.trailing, 10)
                    }
                    .background(Color.orange)
                    .clipShape(Capsule())
                }
            }

            groupedFieldStack {
                HStack {
                    clearableField("Add service", text: $newServiceEntry)
                    Button {
                        addService()
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .semibold))
                            .padding(12)
                            .background(Color.orange)
                            .foregroundStyle(.white)
                            .clipShape(Circle())
                    }
                    .disabled(newServiceEntry.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(.horizontal, 4)
            }
        }
    }

    private var scheduleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Schedule Type")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(.primary)

            Picker("Schedule", selection: $schedule) {
                ForEach(ScheduleType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.menu)
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    private func addService() {
        let trimmed = newServiceEntry.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        if !serviceTags.contains(trimmed) {
            serviceTags.append(trimmed)
        }
        newServiceEntry = ""
    }

    private func removeService(_ service: String) {
        serviceTags.removeAll { $0 == service }
    }

    @ViewBuilder
    private func clearableField(_ title: String,
                                text: Binding<String>,
                                keyboard: UIKeyboardType = .default,
                                autocap: TextInputAutocapitalization = .sentences) -> some View {
        HStack {
            TextField(title, text: text)
                .textInputAutocapitalization(autocap)
                .keyboardType(keyboard)
                .tint(.orange)
                .padding(.vertical, 12)
                .padding(.leading, 12)
                .padding(.trailing, 4)
            if !text.wrappedValue.isEmpty {
                Button {
                    text.wrappedValue = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.orange)
                        .font(.system(size: 16, weight: .semibold))
                        .padding(.trailing, 8)
                }
                .buttonStyle(.plain)
            }
        }
    }

    @ViewBuilder
    private func groupedFieldStack<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        VStack(spacing: 0, content: content)
            .padding(.horizontal, 2)
            .padding(.vertical, 2)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color(.separator), lineWidth: 0.5)
            )
    }
}

#Preview {
    WorkerEditForm(
        name: .constant("Maria Rodriguez"),
        company: .constant("GreenScape"),
        phone: .constant("(555) 123-4567"),
        email: .constant("maria@greenscape.com"),
        specialization: .constant("Gardener"),
        serviceTags: .constant(["Gardener", "Landscaping"]),
        newServiceEntry: .constant(""),
        schedule: .constant(.weekly)
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
