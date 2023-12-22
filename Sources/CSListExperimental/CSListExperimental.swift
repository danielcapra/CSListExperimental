import SwiftUI

/**
    A container that presents rows of data arranged in a single column, similar to `List`, but with the option to create custom styles.

    - Important: This API uses the underscored \_VariadicView APIs which are not *totally public* and are underscored for a reason. They could disappear or change without a deprecation period, so use at own discretion. That being said, people have been successful in shipping apps that use these APIs to the App Store.

    Create lists statically from given content or dynamically from an underlying collection of data. The following example shows how to create a simple static list with some content:
 ```swift
    var body: some View {
        CSListExperimental {
            Text("First Item")
            Text("Second Item")
            Text("Third Item")
        }
    }
 ```
    This example shows how to create a dynamic list from an array of an Ocean type which conforms to Identifiable.

 ```swift
    struct Ocean: Identifiable {
        let name: String
        let id = UUID()
    }

    private var oceans = [
        Ocean(name: "Pacific"),
        Ocean(name: "Atlantic"),
        Ocean(name: "Indian"),
        Ocean(name: "Southern"),
        Ocean(name: "Arctic")
    ]

    var body: some View {
        CSListExperimental(oceans) {
            Text($0.name)
        }
    }
 ```

    **Creating a custom style**
 ```swift
    // Create a custom style by defining a struct which conforms to `CSListExperimentalStyle`
    struct MyCustomStyle: CSListExperimentalStyle {
        func makeBody(configuration: Configuration, children: Children) -> some View {
            VStack(alignment: .leading, spacing: 4) {
                // The provided header in CSListExperimental init
                // If no header was provided this will be an emptyview
                configuration.header
                    .font(.headline)
                    .padding(.leading)
                VStack(spacing: 8) {
                    // loop over children (these are all the views generated from all the rows)
                    ForEach(children) { item in
                        // the view itself for each row
                        item

                        // Each child is identifiable so we can compare them
                        // Divider between items
                        if item.id != children.last?.id {
                            Divider()
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.green)
                        .opacity(0.8)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(.foreground, lineWidth: 2)
                )
                // The provided footer in CSListExperimental init
                // If no header was provided this will be an emptyview
                configuration.footer
                    .font(.caption)
                    .padding(.leading)
            }
        }
    }
 ```
    **Using the custom style**
 ```swift
    var body: some View {
        CSListExperimental(oceans) {
            Text($0.name)
        }
        .csListExperimentalStyle(MyCustomStyle()) // This will affect all child views
    }
 ```

    **Dot notation**
 ```swift
    extension CSListExperimentalStyle where Self == MyCustomStyle {
        static var `myCustomStyle`: Self { MyCustomStyle() }
    }

    // Now use like so
    var body: some View {
        CSListExperimental(oceans) {
            Text($0.name)
        }
        .csListExperimentalStyle(.myCustomStyle) // This will affect all child views
    }
 ```
    - Author: Daniel Capra
 */
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

// MARK: Content Initialisers
public extension CSListExperimental {
    // No header or footer
    /**
     Creates a list with the given content, without a header or a footer.

     ```swift
    var body: some View {
        CSListExperimental {
            Text("Apple")
            Text("Pear")
            Text("Banana")
        }
    }
     ```

     - Author: Daniel Capra
     */
    @MainActor init(
        @ViewBuilder content: () -> Content
    ) where Header == EmptyView, Footer == EmptyView {
        self.configuration = .init(
            label: content(),
            header: EmptyView(),
            footer: EmptyView()
        )
    }

    // Only Header
    /**
     Creates a list with the given content, with a header, but no footer.

     ```swift
    var body: some View {
        CSListExperimental {
            Text("Apple")
            Text("Pear")
            Text("Banana")
        } header: {
            Text("Fruits")
                .font(.headline)
        }
    }
     ```

     - Author: Daniel Capra
     */
    @MainActor init(
        @ViewBuilder content: () -> Content,
        @ViewBuilder header: () -> Header
    ) where Footer == EmptyView {
        self.configuration = .init(
            label: content(),
            header: header(),
            footer: EmptyView()
        )
    }

    // Only Footer
    /**
     Creates a list with the given content, with a footer, but no header.

     ```swift
    var body: some View {
        CSListExperimental {
            Text("Apple")
            Text("Pear")
            Text("Banana")
        } footer: {
            Text("Eat more fruits. They're good for you!")
                .font(.caption)
        }
    }
     ```

     - Author: Daniel Capra
     */
    @MainActor init(
        @ViewBuilder content: () -> Content,
        @ViewBuilder footer: () -> Footer
    ) where Header == EmptyView {
        self.configuration = .init(
            label: content(),
            header: EmptyView(),
            footer: footer()
        )
    }

    // Both header & footer
    /**
     Creates a list with the given content, with both a header and a footer.

     ```swift
    var body: some View {
        CSListExperimental {
            Text("Apple")
            Text("Pear")
            Text("Banana")
        } header: {
            Text("Fruits")
                .font(.headline)
        } footer: {
            Text("Eat more fruits. They're good for you!")
                .font(.caption)
        }
    }
     ```

     - Author: Daniel Capra
     */
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
}

// MARK: Identifiable data initialisers
public extension CSListExperimental {
    // No header or footer
    /**
     Creates a list that computes its rows on demand from an underlying collection of identifiable data, without a header or footer.

     - Parameters:
        - data: A RandomAccessCollection of Identifiable Elements
        - rowContent: A ViewBuilder closure that builds each element's row content

     ```swift
    struct Person: Identifiable {
        let name: String
        let id = UUID()
    }

    let people: [Person] = [
        Person(name: "Rachel"),
        Person(name: "Mike"),
        Person(name: "Harvey"),
        Person(name: "Donna")
    ]

    var body: some View {
        CSListExperimental(people) {
            Text($0.name)
        }
    }
     ```

     - Author: Daniel Capra
     */
    @MainActor init<Data, RowContent>(
        _ data: Data,
        @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent
    ) where
    Content == ForEach<Data, Data.Element.ID, RowContent>,
    Data : RandomAccessCollection,
    Data.Element : Identifiable,
    RowContent : View,
    Header == EmptyView,
    Footer == EmptyView
    {
        self.configuration = .init(
            label: ForEach(data, content: rowContent),
            header: EmptyView(),
            footer: EmptyView()
        )
    }

    // Only header
    /**
     Creates a list that computes its rows on demand from an underlying collection of identifiable data, with a header, but no footer.

     - Parameters:
        - data: A RandomAccessCollection of Identifiable Elements
        - rowContent: A ViewBuilder closure that builds each element's row content
        - header: A ViewBuilder closure that builds the header view

     ```swift
    struct Person: Identifiable {
        let name: String
        let id = UUID()
    }

    let people: [Person] = [
        Person(name: "Rachel"),
        Person(name: "Mike"),
        Person(name: "Harvey"),
        Person(name: "Donna")
    ]

    var body: some View {
        CSListExperimental(people) {
            Text($0.name)
        } header: {
            Text("Suits characters")
                .font(.headline)
        }
    }
     ```

     - Author: Daniel Capra
     */
    @MainActor init<Data, RowContent>(
        _ data: Data,
        @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent,
        @ViewBuilder header: () -> Header
    ) where
    Content == ForEach<Data, Data.Element.ID, RowContent>,
    Data : RandomAccessCollection,
    Data.Element : Identifiable,
    RowContent : View,
    Footer == EmptyView
    {
        self.configuration = .init(
            label: ForEach(data, content: rowContent),
            header: header(),
            footer: EmptyView()
        )
    }

    // Only footer
    /**
     Creates a list that computes its rows on demand from an underlying collection of identifiable data, with a footer, but no header.

     - Parameters:
        - data: A RandomAccessCollection of Identifiable Elements
        - rowContent: A ViewBuilder closure that builds each element's row content
        - footer: A ViewBuilder closure that builds the footer view

     ```swift
    struct Person: Identifiable {
        let name: String
        let id = UUID()
    }

    let people: [Person] = [
        Person(name: "Rachel"),
        Person(name: "Mike"),
        Person(name: "Harvey"),
        Person(name: "Donna")
    ]

    var body: some View {
        CSListExperimental(people) {
            Text($0.name)
        } footer: {
            Text("Suits is an American legal drama television series created and written by Aaron Korsh.")
                .font(.caption)
        }
    }
     ```

     - Author: Daniel Capra
     */
    @MainActor init<Data, RowContent>(
        _ data: Data,
        @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent,
        @ViewBuilder footer: () -> Footer
    ) where
    Content == ForEach<Data, Data.Element.ID, RowContent>,
    Data : RandomAccessCollection,
    Data.Element : Identifiable,
    RowContent : View,
    Header == EmptyView
    {
        self.configuration = .init(
            label: ForEach(data, content: rowContent),
            header: EmptyView(),
            footer: footer()
        )
    }

    // Both header & footer
    /**
         Creates a list that computes its rows on demand from an underlying collection of identifiable data, with a header and a footer.

         - Parameters:
            - data: A RandomAccessCollection of Identifiable Elements
            - rowContent: A ViewBuilder closure that builds each element's row content
            - header: A ViewBuilder closure that builds the header view
            - footer: A ViewBuilder closure that builds the footer view

         ```swift
        struct Person: Identifiable {
            let name: String
            let id = UUID()
        }

        let people: [Person] = [
            Person(name: "Rachel"),
            Person(name: "Mike"),
            Person(name: "Harvey"),
            Person(name: "Donna")
        ]

        var body: some View {
            CSListExperimental(people) {
                Text($0.name)
            } header: {
                Text("Suits characters")
                    .font(.headline)
            } footer: {
                Text("Suits is an American legal drama television series created and written by Aaron Korsh.")
                    .font(.caption)
            }
        }
         ```

         - Author: Daniel Capra
    */
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
}

// MARK: ID Key Path initialisers
public extension CSListExperimental {
    // No header or footer
    /**
     Creates a list that identifies its rows based on a key path to the identifier of the underlying data, without a header or footer.

     - Parameters:
        - data: A RandomAccessCollection
        - id: A key path to the identifier of the data
        - rowContent: A ViewBuilder closure that builds each element's row content

     ```swift
     struct Album {
         let artist: String
         let songs: [String]
     }

     let album = Album(artist: "TAEYEON", songs: [
         "To. X",
         "Melt Away",
         "Burn It Down",
         "Nightmare",
         "All For Nothing",
         "Fabulous"
     ])

    var body: some View {
        CSListExperimental(album.songs, id: \.self) {
            Text($0)
        }
    }
     ```

     - Author: Daniel Capra
     */
    @MainActor init<Data, ID, RowContent>(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent
    ) where
    Content == ForEach<Data, ID, RowContent>,
    Data : RandomAccessCollection,
    ID : Hashable,
    RowContent : View,
    Header == EmptyView,
    Footer == EmptyView
    {
        self.configuration = .init(
            label: ForEach(data, id: id, content: rowContent),
            header: EmptyView(),
            footer: EmptyView()
        )
    }

    // Only header
    /**
     Creates a list that identifies its rows based on a key path to the identifier of the underlying data, with a header, but no footer.

     - Parameters:
        - data: A RandomAccessCollection
        - id: A key path to the identifier of the data
        - rowContent: A ViewBuilder closure that builds each element's row content
        - header: A ViewBuilder closure that builds the header view

     ```swift
    struct Album {
        let artist: String
        let songs: [String]
    }

     let album = Album(artist: "TAEYEON", songs: [
         "To. X",
         "Melt Away",
         "Burn It Down",
         "Nightmare",
         "All For Nothing",
         "Fabulous"
     ])

    var body: some View {
        CSListExperimental(album.songs, id: \.self) {
            Text($0)
        } header: {
            Text(album.artist)
                .font(.headline)
        }
    }
     ```

     - Author: Daniel Capra
     */
    @MainActor init<Data, ID, RowContent>(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent,
        @ViewBuilder header: () -> Header
    ) where
    Content == ForEach<Data, ID, RowContent>,
    Data : RandomAccessCollection,
    ID : Hashable,
    RowContent : View,
    Footer == EmptyView
    {
        self.configuration = .init(
            label: ForEach(data, id: id, content: rowContent),
            header: header(),
            footer: EmptyView()
        )
    }

    // Only footer
    /**
     Creates a list that identifies its rows based on a key path to the identifier of the underlying data, with a footer, but no header.

     - Parameters:
        - data: A RandomAccessCollection
        - id: A key path to the identifier of the data
        - rowContent: A ViewBuilder closure that builds each element's row content
        - footer: A ViewBuilder closure that builds the footer view

     ```swift
    struct Album {
        let artist: String
        let songs: [String]
    }

     let album = Album(artist: "TAEYEON", songs: [
         "To. X",
         "Melt Away",
         "Burn It Down",
         "Nightmare",
         "All For Nothing",
         "Fabulous"
     ])

    var body: some View {
        CSListExperimental(album.songs, id: \.self) {
            Text($0)
        } footer: {
            Text("Kim Tae-yeon, known mononymously as Taeyeon, is a South Korean singer. She debuted as a member of girl group Girls' Generation in August 2007, which went on to become one of the best-selling artists in South Korea and one of the most popular K-pop groups worldwide.")
                .font(.caption)
        }
    }
     ```

     - Author: Daniel Capra
     */
    @MainActor init<Data, ID, RowContent>(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent,
        @ViewBuilder footer: () -> Footer
    ) where
    Content == ForEach<Data, ID, RowContent>,
    Data : RandomAccessCollection,
    ID : Hashable,
    RowContent : View,
    Header == EmptyView
    {
        self.configuration = .init(
            label: ForEach(data, id: id, content: rowContent),
            header: EmptyView(),
            footer: footer()
        )
    }

    // Both header & footer
    /**
     Creates a list that identifies its rows based on a key path to the identifier of the underlying data, with both a header and a footer.

     - Parameters:
        - data: A RandomAccessCollection
        - id: A key path to the identifier of the data
        - rowContent: A ViewBuilder closure that builds each element's row content
        - header: A ViewBuilder closure that builds the header view
        - footer: A ViewBuilder closure that builds the footer view

     ```swift
    struct Album {
        let artist: String
        let songs: [String]
    }

     let album = Album(artist: "TAEYEON", songs: [
         "To. X",
         "Melt Away",
         "Burn It Down",
         "Nightmare",
         "All For Nothing",
         "Fabulous"
     ])

    var body: some View {
        CSListExperimental(album.songs, id: \.self) {
            Text($0)
        } header: {
            Text(album.artist)
                .font(.headline)
        } footer: {
            Text("Kim Tae-yeon, known mononymously as Taeyeon, is a South Korean singer. She debuted as a member of girl group Girls' Generation in August 2007, which went on to become one of the best-selling artists in South Korea and one of the most popular K-pop groups worldwide.")
                .font(.caption)
        }
    }
     ```

     - Author: Daniel Capra
     */
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
}

// MARK: Range initialisers
public extension CSListExperimental {
    // No header or footer
    /**
     Creates a list that identifies its views on demand over a constant range, with no header or footer.

     - Parameters:
        - data: A constant range of integers
        - rowContent: A ViewBuilder closure that builds each row content

     ```swift
     var body: some View {
         CSListExperimental(0..<3) { number in
             Text(number, format: .number)
         }
     }
     ```

     - Author: Daniel Capra
     */
    @MainActor init<RowContent>(
        _ data: Range<Int>,
        @ViewBuilder rowContent: @escaping (Int) -> RowContent
    ) where
    Content == ForEach<Range<Int>, Int, RowContent>,
    RowContent : View,
    Header == EmptyView,
    Footer == EmptyView
    {
        self.configuration = .init(
            label: ForEach(data, content: rowContent),
            header: EmptyView(),
            footer: EmptyView()
        )
    }

    // Only header
    /**
     Creates a list that identifies its views on demand over a constant range, with a header, but no footer.

     - Parameters:
        - data: A constant range of integers
        - rowContent: A ViewBuilder closure that builds each row content
        - header: A ViewBuilder closure that builds the header view

     ```swift
     var body: some View {
         CSListExperimental(0..<3) { number in
             Text(number, format: .number)
         } header: {
             Text("Some numbers")
                .font(.headline)
         }
     }
     ```

     - Author: Daniel Capra
     */
    @MainActor init<RowContent>(
        _ data: Range<Int>,
        @ViewBuilder rowContent: @escaping (Int) -> RowContent,
        @ViewBuilder header: () -> Header
    ) where
    Content == ForEach<Range<Int>, Int, RowContent>,
    RowContent : View,
    Footer == EmptyView
    {
        self.configuration = .init(
            label: ForEach(data, content: rowContent),
            header: header(),
            footer: EmptyView()
        )
    }

    // Only footer
    /**
     Creates a list that identifies its views on demand over a constant range, with a footer, but no header.

     - Parameters:
        - data: A constant range of integers
        - rowContent: A ViewBuilder closure that builds each row content
        - footer: A ViewBuilder closure that builds the footer view

     ```swift
     var body: some View {
         CSListExperimental(0..<3) { number in
             Text(number, format: .number)
         } footer: {
             Text("An integer is a whole number that can be positive, negative, or zero.")
                .font(.caption)
         }
     }
     ```

     - Author: Daniel Capra
     */
    @MainActor init<RowContent>(
        _ data: Range<Int>,
        @ViewBuilder rowContent: @escaping (Int) -> RowContent,
        @ViewBuilder footer: () -> Footer
    ) where
    Content == ForEach<Range<Int>, Int, RowContent>,
    RowContent : View,
    Header == EmptyView
    {
        self.configuration = .init(
            label: ForEach(data, content: rowContent),
            header: EmptyView(),
            footer: footer()
        )
    }

    // Both header & footer
    /**
     Creates a list that identifies its views on demand over a constant range, with both a header and a footer.

     - Parameters:
        - data: A constant range of integers
        - rowContent: A ViewBuilder closure that builds each row content
        - header: A ViewBuilder closure that builds the header view
        - footer: A ViewBuilder closure that builds the footer view

     ```swift
     var body: some View {
         CSListExperimental(0..<3) { number in
             Text(number, format: .number)
         } header: {
             Text("Some numbers")
                .font(.headline)
         } footer: {
             Text("An integer is a whole number that can be positive, negative, or zero.")
                .font(.caption)
         }
     }
     ```

     - Author: Daniel Capra
     */
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
