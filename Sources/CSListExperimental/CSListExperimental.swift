import SwiftUI

public struct CSListExperimental<Content, Header, Footer> where Content : View, Header : View, Footer : View {
    @Environment(\.csExperimentalListStyle) private var style

    private let configuration: CSListExperimentalConfiguration
}

internal struct CSListExperimentalLayout<Content: View>: _VariadicView_UnaryViewRoot {

    @ViewBuilder
    var makeBody: (_VariadicView.Children) -> Content


    @ViewBuilder
    func body(children: _VariadicView.Children) -> some View {
        makeBody(children)
    }

    init(makeBody: @escaping (_VariadicView.Children) -> Content) {
        self.makeBody = makeBody
    }
}

extension CSListExperimental: View {
    @MainActor public var body: some View {
        let layout = CSListExperimentalLayout { children in
            AnyView(style.makeBody(configuration: configuration, children: children))
        }
        _VariadicView.Tree(layout) {
            configuration.label
        }
    }
}

// MARK: Initialisers with no Header or Footer
public extension CSListExperimental where Header == EmptyView, Footer == EmptyView {
    @MainActor init(
        @ViewBuilder content: () -> Content
    ) {
        self.configuration = .init(
            label: content(),
            header: EmptyView(),
            footer: EmptyView()
        )
    }

    @MainActor init<Data, RowContent>(
        _ data: Data,
        @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent
    ) where
    Content == ForEach<Data, Data.Element.ID, RowContent>,
    Data : RandomAccessCollection,
    Data.Element : Identifiable,
    RowContent : View
    {
        self.configuration = .init(
            label: ForEach(data, content: rowContent),
            header: EmptyView(),
            footer: EmptyView()
        )
    }

    @MainActor init<Data, ID, RowContent>(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent
    ) where
    Content == ForEach<Data, ID, RowContent>,
    Data : RandomAccessCollection,
    ID : Hashable,
    RowContent : View 
    {
        self.configuration = .init(
            label: ForEach(data, id: id, content: rowContent),
            header: EmptyView(),
            footer: EmptyView()
        )
    }

    @MainActor init<RowContent>(
        _ data: Range<Int>,
        @ViewBuilder rowContent: @escaping (Int) -> RowContent
    ) where
    Content == ForEach<Range<Int>, Int, RowContent>,
    RowContent : View
    {
        self.configuration = .init(
            label: ForEach(data, content: rowContent),
            header: EmptyView(),
            footer: EmptyView()
        )
    }
}

// MARK: Initialisers with no Footer
public extension CSListExperimental where Footer == EmptyView {
    @MainActor init(
        @ViewBuilder content: () -> Content,
        @ViewBuilder header: () -> Header
    ) {
        self.configuration = .init(
            label: content(),
            header: header(),
            footer: EmptyView()
        )
    }

    @MainActor init<Data, RowContent>(
        _ data: Data,
        @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent,
        @ViewBuilder header: () -> Header
    ) where
    Content == ForEach<Data, Data.Element.ID, RowContent>,
    Data : RandomAccessCollection,
    Data.Element : Identifiable,
    RowContent : View
    {
        self.configuration = .init(
            label: ForEach(data, content: rowContent),
            header: header(),
            footer: EmptyView()
        )
    }

    @MainActor init<Data, ID, RowContent>(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent,
        @ViewBuilder header: () -> Header
    ) where
    Content == ForEach<Data, ID, RowContent>,
    Data : RandomAccessCollection,
    ID : Hashable,
    RowContent : View
    {
        self.configuration = .init(
            label: ForEach(data, id: id, content: rowContent),
            header: header(),
            footer: EmptyView()
        )
    }

    @MainActor init<RowContent>(
        _ data: Range<Int>,
        @ViewBuilder rowContent: @escaping (Int) -> RowContent,
        @ViewBuilder header: () -> Header
    ) where
    Content == ForEach<Range<Int>, Int, RowContent>,
    RowContent : View
    {
        self.configuration = .init(
            label: ForEach(data, content: rowContent),
            header: header(),
            footer: EmptyView()
        )
    }
}

// MARK: Initialisers with no Header
public extension CSListExperimental where Header == EmptyView {
    @MainActor init(
        @ViewBuilder content: () -> Content,
        @ViewBuilder footer: () -> Footer
    ) {
        self.configuration = .init(
            label: content(),
            header: EmptyView(),
            footer: footer()
        )
    }

    @MainActor init<Data, RowContent>(
        _ data: Data,
        @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent,
        @ViewBuilder footer: () -> Footer
    ) where
    Content == ForEach<Data, Data.Element.ID, RowContent>,
    Data : RandomAccessCollection,
    Data.Element : Identifiable,
    RowContent : View
    {
        self.configuration = .init(
            label: ForEach(data, content: rowContent),
            header: EmptyView(),
            footer: footer()
        )
    }

    @MainActor init<Data, ID, RowContent>(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent,
        @ViewBuilder footer: () -> Footer
    ) where
    Content == ForEach<Data, ID, RowContent>,
    Data : RandomAccessCollection,
    ID : Hashable,
    RowContent : View
    {
        self.configuration = .init(
            label: ForEach(data, id: id, content: rowContent),
            header: EmptyView(),
            footer: footer()
        )
    }

    @MainActor init<RowContent>(
        _ data: Range<Int>,
        @ViewBuilder rowContent: @escaping (Int) -> RowContent,
        @ViewBuilder footer: () -> Footer
    ) where
    Content == ForEach<Range<Int>, Int, RowContent>,
    RowContent : View
    {
        self.configuration = .init(
            label: ForEach(data, content: rowContent),
            header: EmptyView(),
            footer: footer()
        )
    }
}

// MARK: Initialisers with both Header & Footer
public extension CSListExperimental {
    @MainActor init(
        @ViewBuilder content: () -> Content,
        @ViewBuilder header: () -> Header,
        @ViewBuilder footer: () -> Footer
    ) {
        self.configuration = .init(
            label: content(),
            header: header(),
            footer: footer()
        )
    }

    @MainActor init<Data, RowContent>(
        _ data: Data,
        @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent,
        @ViewBuilder header: () -> Header,
        @ViewBuilder footer: () -> Footer
    ) where
    Content == ForEach<Data, Data.Element.ID, RowContent>,
    Data : RandomAccessCollection,
    Data.Element : Identifiable,
    RowContent : View
    {
        self.configuration = .init(
            label: ForEach(data, content: rowContent),
            header: header(),
            footer: footer()
        )
    }

    @MainActor init<Data, ID, RowContent>(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent,
        @ViewBuilder header: () -> Header,
        @ViewBuilder footer: () -> Footer
    ) where
    Content == ForEach<Data, ID, RowContent>,
    Data : RandomAccessCollection,
    ID : Hashable,
    RowContent : View
    {
        self.configuration = .init(
            label: ForEach(data, id: id, content: rowContent),
            header: header(),
            footer: footer()
        )
    }

    @MainActor init<RowContent>(
        _ data: Range<Int>,
        @ViewBuilder rowContent: @escaping (Int) -> RowContent,
        @ViewBuilder header: () -> Header,
        @ViewBuilder footer: () -> Footer
    ) where
    Content == ForEach<Range<Int>, Int, RowContent>,
    RowContent : View
    {
        self.configuration = .init(
            label: ForEach(data, content: rowContent),
            header: header(),
            footer: footer()
        )
    }
}

// MARK: - Configuration
public struct CSListExperimentalConfiguration {
    fileprivate let label: AnyView
    public let header: AnyView
    public let footer: AnyView

    init(
        label: some View,
        header: some View,
        footer: some View
    ) {
        self.label = AnyView(label)
        self.header = AnyView(header)
        self.footer = AnyView(footer)
    }
}

// MARK: - Style protocol
public protocol CSListExperimentalStyle {
    @ViewBuilder func makeBody(configuration: Configuration, children: Children) -> Body

    associatedtype Body : View
    typealias Children = _VariadicView.Children
    typealias Configuration = CSListExperimentalConfiguration
}

// MARK: - Default Style
public struct CSListExperimentalDefaultStyle: CSListExperimentalStyle {
    public func makeBody(configuration: Configuration, children: Children) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            configuration.header
                .padding(.leading)
            VStack(spacing: 8) {
                ForEach(children) { child in
                    child

                    if child.id != children.last?.id {
                        Divider()
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.green)
                    .opacity(0.5)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(.black, lineWidth: 2)
            )
            configuration.footer
                .padding(.leading)
        }
    }
}

// MARK: - View Modifier
public struct CSListExperimentalStyleModifier: ViewModifier {
    let style: any CSListExperimentalStyle

    init(style: some CSListExperimentalStyle) {
        self.style = style
    }

    public func body(content: Content) -> some View {
        content
            .environment(\.csExperimentalListStyle, style)
    }
}

public extension View {
    func csListExperimentalStyle(_ style: some CSListExperimentalStyle) -> some View {
        modifier(CSListExperimentalStyleModifier(style: style))
    }
}

public extension CSListExperimentalStyle where Self == CSListExperimentalDefaultStyle {
    static var `default`: Self { CSListExperimentalDefaultStyle() }
}

// MARK: - Environment
public struct CSListExperimentalStyleKey: EnvironmentKey {
    public static var defaultValue: any CSListExperimentalStyle = CSListExperimentalDefaultStyle()
}

public extension EnvironmentValues {
    var csExperimentalListStyle: any CSListExperimentalStyle {
        get { self[CSListExperimentalStyleKey.self] }
        set { self[CSListExperimentalStyleKey.self] = newValue }
    }
}
