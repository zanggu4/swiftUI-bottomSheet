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
    @State private var showDynamicHeightSheet = false
    @State private var showPagingSheet = false
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

                Button("Dynamic Height Change") {
                    showDynamicHeightSheet = true
                }

                Button("Paging Height Change") {
                    showPagingSheet = true
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
            VStack(spacing: 0) {
                Text("Content")
                    .background(Color.blue)
                Text("Content")
                    .background(Color.green)
                Text("Content")
                    .background(Color.red)
                Text("Content")
                    .background(Color.yellow)
                Text("Content")
                    .background(Color.purple)
                Text("Content")
                    .background(Color.gray)
            }

//            BasicSheetContent()
        }
        .overlaySheet(
            isPresented: $showHeaderSheet,
            header: {
                Text("Header")
                    .background(Color.red)
            },
            content: {
                VStack {
                    Text("Content")
                    Text("Content")
                    Text("Content")
                    Text("Content")
                    Text("Content")
                    Text("Content")
                }
                .background(Color.blue)
            }
        )
        .overlaySheet(isPresented: $showDynamicHeightSheet) {
            DynamicHeightSheetContent()
        }
        .overlaySheet(isPresented: $showPagingSheet) {
            PagingHeightSheetContent()
        }
        .overlaySheet(isPresented: $showLongContentSheet) {
            LongSheetContent()
        }
        .overlaySheet(isPresented: $showKeyboardSheet) {
            KeyboardSheetContent()
        }
        .overlaySheet(item: $selectedItem) { item in
            ItemSheetContent(item: item)
        }
        .presentBottomSheet(
            isPresented: $showPresentSheet,
            header: {
                Text("Header")
                    .background(Color.red)
            },
            content: {
                VStack {
                    Text("Content")
                    Text("Content")
                    Text("Content")
                    Text("Content")
                    Text("Content")
                    Text("Content")
                }
                .background(Color.blue)
            }
        )
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

struct DynamicHeightSheetContent: View {
    @State private var items: [String] = ["Item 1"]
    @State private var isExpanded = false

    var body: some View {
        VStack(spacing: 16) {
            GrabHandle()

            Text("Dynamic Height")
                .font(.title3.bold())

            Text("버튼을 눌러 콘텐츠를 추가/제거하면\n시트 높이가 자동으로 변합니다.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            // 토글로 펼치기/접기
            Button {
                isExpanded.toggle()
            } label: {
                HStack {
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    Text(isExpanded ? "설명 접기" : "설명 펼치기")
                }
                .font(.subheadline.bold())
                .foregroundColor(.purple)
            }

            if isExpanded {
                Text("이 영역은 펼치기/접기로 동적으로 나타나고 사라집니다. 시트 높이가 콘텐츠에 맞춰 자연스럽게 변하는지 확인해보세요.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.purple.opacity(0.08))
                    .cornerRadius(8)
            }

            // 아이템 리스트
            ForEach(items, id: \.self) { item in
                HStack {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 8))
                        .foregroundColor(.blue)
                    Text(item)
                        .font(.body)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.05))
                .cornerRadius(8)
            }

            // 추가/제거 버튼
            HStack(spacing: 12) {
                Label("추가", systemImage: "plus.circle.fill")
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .onTapGesture {
                        items.append("Item \(items.count + 1)")
                    }

                Label("제거", systemImage: "minus.circle.fill")
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(items.count > 1 ? Color.red : Color.gray)
                    .cornerRadius(10)
                    .onTapGesture {
                        if items.count > 1 {
                            items.removeLast()
                        }
                    }
                    .disabled(items.count <= 1)
            }
            .padding(.horizontal, 16)

            Spacer().frame(height: 16)
        }
        .padding(.horizontal, 16)
    }
}

// MARK: - Page Height Measurement

private struct PageHeightKey: PreferenceKey {
    static var defaultValue: [Int: CGFloat] = [:]
    static func reduce(value: inout [Int: CGFloat], nextValue: () -> [Int: CGFloat]) {
        value.merge(nextValue()) { _, new in new }
    }
}

private struct MeasurePageHeight: View {
    let page: Int
    var body: some View {
        GeometryReader { geo in
            Color.clear.preference(key: PageHeightKey.self, value: [page: geo.size.height])
        }
    }
}

// MARK: - Paging Height Sheet

struct PagingHeightSheetContent: View {
    @State private var currentPage = 0
    @State private var pageHeights: [Int: CGFloat] = [:]
    private let pageCount = 3

    var body: some View {
        VStack(spacing: 16) {
            GrabHandle()

            Text("Paging Height")
                .font(.title3.bold())

            Text("좌우로 스와이프하면 페이지마다\n다른 높이의 콘텐츠가 표시됩니다.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            TabView(selection: $currentPage) {
                ForEach(0 ..< pageCount, id: \.self) { index in
                    pageContent(for: index)
                        .background(MeasurePageHeight(page: index))
                        .frame(maxHeight: .infinity, alignment: .top)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .frame(height: pageHeights[currentPage] ?? 120)
            .onPreferenceChange(PageHeightKey.self) { pageHeights = $0 }

            Spacer().frame(height: 16)
        }
    }

    @ViewBuilder
    private func pageContent(for page: Int) -> some View {
        switch page {
        case 0:
            VStack(spacing: 12) {
                Image(systemName: "1.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
                Text("간단한 페이지")
                    .font(.headline)
                Text("콘텐츠가 적어 시트가 낮습니다.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
        case 1:
            VStack(spacing: 10) {
                Image(systemName: "2.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.orange)
                Text("중간 페이지")
                    .font(.headline)
                ForEach(1 ... 4, id: \.self) { i in
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                        Text("항목 \(i)")
                            .font(.subheadline)
                        Spacer()
                    }
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(Color.orange.opacity(0.08))
                    .cornerRadius(8)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
        default:
            VStack(spacing: 10) {
                Image(systemName: "3.circle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.green)
                Text("긴 페이지")
                    .font(.headline)
                Text("콘텐츠가 많아 시트가 높아집니다.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                ForEach(1 ... 8, id: \.self) { i in
                    HStack(spacing: 12) {
                        Circle()
                            .fill(Color.green.opacity(0.2))
                            .frame(width: 32, height: 32)
                            .overlay(
                                Text("\(i)")
                                    .font(.caption.bold())
                                    .foregroundColor(.green)
                            )
                        Text("리스트 아이템 \(i)")
                            .font(.subheadline)
                        Spacer()
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 12)
                    .background(Color.green.opacity(0.05))
                    .cornerRadius(8)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
        }
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
