import SwiftUI

public class SVGPath: SVGShape, ObservableObject {

    @Published public var segments: [PathSegment]
    @Published public var fillRule: CGPathFillRule

    public init(segments: [PathSegment] = [], fillRule: CGPathFillRule = .winding) {
        self.segments = segments
        self.fillRule = fillRule
    }

    override public func toSwiftUI() -> AnyView {
        AnyView(SVGPathView(model: self))
    }

    override func serialize(_ serializer: Serializer) {
        let path = segments.map { s in "\(s.type)\(s.data.compactMap { $0.serialize() }.joined(separator: ","))" }.joined(separator: " ")
        serializer.add("path", path)
        serializer.add("fillRule", fillRule)
        super.serialize(serializer)
    }
}

struct SVGPathView: View {

    @ObservedObject var model = SVGPath()

    public var body: some View {
        model.toBezierPath().toSwiftUI(model: model)
    }
}

extension MBezierPath {

    func toSwiftUI(model: SVGShape) -> some View {
        let path = Path(self.cgPath)

        var result = AnyView(path
            .apply(paint: model.fill)
            .transformEffect(model.transform))

        if let stroke = model.stroke {
            result = AnyView(result.overlay(path.stroke(stroke.fill, style: stroke.toSwiftUI())))
        }

        return result
    }
}

