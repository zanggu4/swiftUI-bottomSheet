import BottomSheet
import SwiftUI

// MARK: - Demo Item

struct DemoItem: Identifiable, Equatable {
    let id: String
    let title: String
    let description: String
}

// MARK: - ContentView

struct ContentView: View {
    @State private var showBasicSheet = false
    @State private var showHeaderSheet = false
    @State private var showLongContentSheet = false
    @State private var showKeyboardSheet = false
    @State private var showPresentSheet = false
    @State private var selectedItem: DemoItem?

    var body: some View {
        List {
            Section {
                Text("Overlay 방식은 현재 화면 위에 ZStack으로 바텀시트를 올립니다.\nPresent 방식은 UIViewController.present()로 표시합니다.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Section("Overlay Style") {
                Button("Basic Bottom Sheet") {
                    showBasicSheet = true
                }

                Button("With Custom Header") {
                    showHeaderSheet = true
                }

                Button("Long Scrollable Content") {
                    showLongContentSheet = true
                }

                Button("With Keyboard Avoidance") {
                    showKeyboardSheet = true
                }

                Button("Item Binding Sheet") {
                    selectedItem = DemoItem(
                        id: "42",
                        title: "Item Detail",
                        description: "Binding<Item?>으로 열리는 바텀시트입니다."
                    )
                }
            }

            Section("Present Style") {
                Button("Present Bottom Sheet") {
                    showPresentSheet = true
                }
            }
        }
        .overlaySheet(isPresented: $showBasicSheet) {
            BasicSheetContent()
        }
        .overlaySheet(
            isPresented: $showHeaderSheet,
            content: {
                HeaderSheetContent()
            }
        )
        .overlaySheet(isPresented: $showLongContentSheet) {
            LongSheetContent()
        }
        .overlaySheet(isPresented: $showKeyboardSheet) {
            KeyboardSheetContent()
        }
        .overlaySheet(item: $selectedItem) { item in
            ItemSheetContent(item: item)
        }

        // MARK: - Present Sheet

        .presentBottomSheet(isPresented: $showPresentSheet) {
            PresentSheetContent(onDismiss: { showPresentSheet = false })
        }
    }
}

// MARK: - Reusable Header

struct SheetHeader: View {
    let title: String
    let onClose: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .trailing) {
                Text(title)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 13)

                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(8)
                }
                .padding(.trailing, 8)
            }
            .padding(.top, 10)
            .padding(.horizontal, 16)

            Divider()
        }
    }
}

// MARK: - Sheet Contents

struct GrabHandle: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(Color.secondary.opacity(0.4))
            .frame(width: 40, height: 4)
            .padding(.top, 12)
    }
}

struct BasicSheetContent: View {
    var body: some View {
        VStack(spacing: 16) {
            GrabHandle()

            Text("Basic Bottom Sheet")
                .font(.title2.bold())

            Text("아래로 드래그하거나 딤 영역을 탭하면 닫힙니다.\n좌측 엣지 스와이프도 지원합니다.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Image(systemName: "hand.draw")
                .font(.system(size: 48))
                .foregroundColor(.blue)
                .padding()

            Spacer().frame(height: 20)
        }
        .padding(.horizontal, 24)
    }
}

struct HeaderSheetContent: View {
    var body: some View {
        VStack(spacing: 0) {
            ForEach(
                [
                    ("bell", "Notifications"),
                    ("paintpalette", "Appearance"),
                    ("lock.shield", "Privacy"),
                    ("globe", "Language"),
                ],
                id: \.1
            ) { icon, title in
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .foregroundColor(.blue)
                        .frame(width: 24)
                    Text(title)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 14)
                .padding(.horizontal, 20)

                if title != "Language" {
                    Divider().padding(.leading, 56)
                }
            }
        }
        .padding(.bottom, 20)
    }
}

struct LongSheetContent: View {
    var body: some View {
        VStack(spacing: 0) {
            GrabHandle()

            Text("Scrollable Content")
                .font(.title3.bold())
                .padding(.vertical, 12)

            ForEach(1 ... 30, id: \.self) { index in
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color.blue.opacity(0.15))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text("\(index)")
                                .font(.caption.bold())
                                .foregroundColor(.blue)
                        )

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Item \(index)")
                            .font(.body)
                        Text("스크롤하여 더 많은 항목을 확인하세요")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
            }
        }
    }
}

struct KeyboardSheetContent: View {
    @State private var name = ""
    @State private var email = ""
    @State private var message = ""

    var body: some View {
        VStack(spacing: 16) {
            GrabHandle()

            Text("Keyboard Avoidance")
                .font(.title3.bold())

            Text("텍스트필드를 탭하면 시트가 키보드 위로 올라갑니다.")
                .font(.caption)
                .foregroundColor(.secondary)

            VStack(spacing: 12) {
                TextField("Name", text: $name)
                    .textFieldStyle(.roundedBorder)

                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.emailAddress)

                TextField("Message", text: $message)
                    .textFieldStyle(.roundedBorder)
            }
            .padding(.horizontal, 16)

            Button(action: {}) {
                Text("Submit")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 16)

            Spacer().frame(height: 16)
        }
    }
}

struct ItemSheetContent: View {
    let item: DemoItem

    var body: some View {
        VStack(spacing: 16) {
            GrabHandle()

            Text(item.title)
                .font(.title2.bold())

            Text(item.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Label("ID: \(item.id)", systemImage: "number")
                .font(.caption)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)

            Spacer().frame(height: 20)
        }
        .padding(.horizontal, 24)
    }
}

struct PresentSheetContent: View {
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            GrabHandle()

            Text("Present Style")
                .font(.title2.bold())

            Text("UIViewController.present()로 표시되는 바텀시트입니다.\n별도 UIWindow 위에 올라가므로\nNavigationView와 독립적입니다.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            Image(systemName: "rectangle.portrait.on.rectangle.portrait")
                .font(.system(size: 48))
                .foregroundColor(.orange)
                .padding()

            Button(action: onDismiss) {
                Text("Close")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.orange)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)

            Spacer().frame(height: 16)
        }
        .padding(.horizontal, 24)
    }
}

#Preview {
    ContentView()
}
