import SwiftUI
import UIKit

struct CustomTextField: UIViewRepresentable {
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: CustomTextField

        init(parent: CustomTextField) {
            self.parent = parent
        }

        @objc func doneTapped() {
            parent.textField.resignFirstResponder()
        }
    }

    var placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType

    var textField = UITextField()

    func makeUIView(context: Context) -> UITextField {
        textField.placeholder = placeholder
        textField.text = text
        textField.keyboardType = keyboardType
        textField.delegate = context.coordinator

        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: context.coordinator, action: #selector(Coordinator.doneTapped))
        toolbar.setItems([doneButton], animated: true)

        textField.inputAccessoryView = toolbar
        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
}
