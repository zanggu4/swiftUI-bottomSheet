//
//  DatePickerSheet.swift
//  DesignSystem
//
//  Created by 이현재 on 10/2/25.
//

import SwiftUI
import UIKit

// MARK: - Public API: View Extension

public extension View {
    /// iOS 버전에 맞춰 적절한 DatePicker 시트를 표시하는 모디파이어입니다.
    /// - iOS 16 이상: `.presentationDetents([.wrap])`을 사용한 네이티브 시트
    /// - iOS 15 이하: `UIWindow`를 이용한 커스텀 전체 화면 시트
    ///
    /// - Parameters:
    ///   - isPresented: 시트의 표시 여부를 제어하는 바인딩.
    ///   - selection: 선택된 날짜를 저장하는 바인딩.
    ///   - components: DatePicker에 표시할 컴포넌트 (예: `.date`, `.hourAndMinute`).
    func datePickerSheet(
        isPresented: Binding<Bool>,
        selection: Binding<Date?>,
        dateRange: ClosedRange<Date>? = nil,
        components: DatePickerComponents = [.date],
        accessoryView: @escaping (() -> some View) = { EmptyView() },
    ) -> some View {
        modifier(
            DatePickerSheetModifier(
                isPresented: isPresented,
                selection: selection,
                dateRange: dateRange,
                components: components,
                accessoryView: accessoryView,
            ),
        )
    }
}

// MARK: - Core Modifier

private struct DatePickerSheetModifier<AccessoryView: View>: ViewModifier {
    @Binding var isPresented: Bool
    @Binding var selection: Date?
    let dateRange: ClosedRange<Date>?
    let components: DatePickerComponents
    let accessoryView: (() -> AccessoryView)?

    private var nonNullSelection: Binding<Date> {
        .init(
            get: { selection ?? dateRange?.upperBound ?? Date() },
            set: {
                selection = $0
            },
        )
    }

    @State private var height: CGFloat = 1

    func body(content: Content) -> some View {
        Group {
            if #available(iOS 16.0, *) {
                // iOS 16 이상: 표준 sheet 사용
                content.sheet(isPresented: $isPresented) {
                    DatePickerSheetView(
                        selection: nonNullSelection,
                        dateRange: dateRange,
                        components: components,
                        accessoryView: accessoryView,
                    )
                    .background(
                        GeometryReader { geometry in
                            Color.clear
                                .onAppear {
                                    height = min(geometry.size.height, 500)
                                }
                                .onChange(of: geometry.size.height) { newValue in
                                    height = min(newValue, 500)
                                }
                        },
                    )
                    .presentationDetents([.height(height)])
                }
            } else {
                // iOS 15 이하: UIWindow를 이용한 커스텀 전체 화면 오버레이 시트
                content.background(
                    FullScreenSheetHelper(
                        isPresented: $isPresented,
                        selection: nonNullSelection,
                        dateRange: dateRange,
                        components: components,
                        accessoryView: accessoryView,
                    ),
                )
            }
        }
        .onAppear {
            if isPresented, selection == nil {
                selection = dateRange?.upperBound ?? Date()
            }
        }
        .onChange(of: isPresented) { isPresented in
            if isPresented, selection == nil {
                selection = dateRange?.upperBound ?? Date()
            }
        }
    }
}

// MARK: - iOS 15 Solution: UIWindow Overlay

private struct FullScreenSheetHelper<AccessoryView: View>: UIViewRepresentable {
    @Binding var isPresented: Bool
    @Binding var selection: Date
    let dateRange: ClosedRange<Date>?
    let components: DatePickerComponents
    let accessoryView: (() -> AccessoryView)?

    func makeUIView(context _: Context) -> UIView {
        UIView() // 레이아웃에 영향을 주지 않는 빈 뷰
    }

    func updateUIView(_: UIView, context: Context) {
        if isPresented {
            context.coordinator.presentSheet()
        } else {
            context.coordinator.dismissSheet()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    @MainActor
    class Coordinator {
        let parent: FullScreenSheetHelper
        private var sheetWindow: UIWindow?

        init(parent: FullScreenSheetHelper) {
            self.parent = parent
        }

        func presentSheet() {
            if sheetWindow != nil { return }

            let sheetView = CustomDatePickerSheet_iOS15(
                isPresented: parent.$isPresented,
                selection: parent.$selection,
                dateRange: parent.dateRange,
                components: parent.components,
                accessoryView: parent.accessoryView,
            )

            let hostingController = UIHostingController(rootView: sheetView)
            hostingController.view.backgroundColor = .clear

            guard let windowScene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else { return }

            let newWindow = UIWindow(windowScene: windowScene)
            newWindow.rootViewController = hostingController
            newWindow.windowLevel = .alert + 1
            newWindow.makeKeyAndVisible()

            sheetWindow = newWindow
        }

        func dismissSheet() {
            guard let window = sheetWindow else { return }

            UIView.animate(withDuration: 0.25, animations: {
                window.alpha = 0
            }) { _ in
                window.isHidden = true
                self.sheetWindow = nil
            }
        }
    }
}

// MARK: - iOS 15 Custom Sheet UI

private struct CustomDatePickerSheet_iOS15<AccessoryView: View>: View {
    @Binding var isPresented: Bool
    @Binding var selection: Date
    let dateRange: ClosedRange<Date>?
    let components: DatePickerComponents
    let accessoryView: (() -> AccessoryView)?

    var body: some View {
        ZStack(alignment: .bottom) {
            // 반투명 배경 (탭하면 닫힘)
            ColorChip.gray100.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { isPresented = false }
                .transition(.opacity)

            // DatePicker 컨텐츠
            DatePickerSheetView(
                selection: $selection,
                dateRange: dateRange,
                components: components,
                accessoryView: accessoryView,
            )
            .padding(.bottom, 30) // 하단 Safe Area 여백
            .background(Color(.systemBackground))
            .cornerRadius(16, corners: [.topLeft, .topRight])
            .transition(.move(edge: .bottom))
        }
        .ignoresSafeArea(.all, edges: .bottom)
        .animation(.easeInOut(duration: 0.25), value: isPresented)
    }
}

// MARK: - Shared DatePicker Content View

private struct DatePickerSheetView<AccessoryView: View>: View {
    @Binding var selection: Date
    let dateRange: ClosedRange<Date>?
    let components: DatePickerComponents
    let accessoryView: (() -> AccessoryView)?

    var body: some View {
        VStack {
            if let accessoryView {
                accessoryView()
            }
            Group {
                if let dateRange {
                    DatePicker(
                        "",
                        selection: $selection,
                        in: dateRange,
                        displayedComponents: components,
                    )
                } else {
                    DatePicker(
                        "",
                        selection: $selection,
                        displayedComponents: components,
                    )
                }
            }
            .datePickerStyle(.wheel)
            .labelsHidden()
            .padding(.horizontal)
        }
    }
}

// MARK: - Helper Extensions

private extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

private struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// MARK: - Example Usage (사용 예시)

struct ContentView: View {
    @State private var showDatePicker = false
    @State private var selectedDate: Date? = Date()

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("선택된 날짜:")
                    .font(.headline)
                Text(selectedDate?.util.toString() ?? "")
                    .font(.title)

                // 화면의 일부만 차지하는 뷰 내부에 버튼을 배치하여 테스트
                VStack {
                    Text("이 뷰는 화면의 일부입니다.")
                        .padding()
                        .background(Color.yellow.opacity(0.3))
                        .cornerRadius(8)

                    Button("날짜 선택 시트 열기") {
                        showDatePicker = true
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(40)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(12)

                Spacer()
            }
            .padding()
            .navigationTitle("DatePicker Sheet")
            // 모디파이어를 뷰 어디에든 적용할 수 있습니다.
            .datePickerSheet(
                isPresented: $showDatePicker,
                selection: $selectedDate,
                components: [.date],
                accessoryView: { EmptyView() },
            )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
