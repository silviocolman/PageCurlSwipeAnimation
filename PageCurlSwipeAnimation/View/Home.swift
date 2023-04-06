//
//  Home.swift
//  PageCurlSwipeAnimation
//
//  Created by Silvio Colmán on 2023-04-05.
//

import SwiftUI

struct Home: View {
    /// Ejemplos de imágenes para mostrar.
    @State private var images: [ImageModel] = []
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                ForEach(images) { image in
                    PeelEffect {
                        CardView(image)
                    } onDelete: {
                        /// Borrar tarjeta.
                        if let index = images.firstIndex(where: { C1 in
                            C1.id == image.id
                        }) {
                            let _ = withAnimation(.easeInOut(duration: 0.35)) {
                                images.remove(at: index)
                            }
                        }
                    }

                }
            }
            .padding(15)
        }
        .onAppear {
            for index in 1...4 {
                images.append(.init(assetName: "pic\(index)"))
            }
        }
    }
    
    /// Vista de tarjeta
    @ViewBuilder
    func CardView(_ imageModel: ImageModel) -> some View {
        GeometryReader {
            let size = $0.size
            
            ZStack {
                Image(imageModel.assetName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size.width, height: size.height)
                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            }
        }
        .frame(height: 130)
        .contentShape(Rectangle())
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
/// Modelo de visualización de imágenes.
/// El scrollview utiliza este modelo para mostrar una lista de las fotos que están disponibles en los assets.
struct ImageModel: Identifiable {
    var id: UUID = .init()
    var assetName: String
}
