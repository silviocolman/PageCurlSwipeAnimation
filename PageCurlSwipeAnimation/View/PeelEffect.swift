//
//  PeelEffect.swift
//  PageCurlSwipeAnimation
//
//  Created by Silvio Colmán on 2023-04-05.
//

import SwiftUI

/// Constructor de vistas personalizadas.
struct PeelEffect<Content:View>: View {
    var content: Content
    /// Llamada de retorno para MainView, cuando se pulsa eliminar.
    var onDelete: () -> ()
    
    init(@ViewBuilder content: @escaping () -> Content, onDelete: @escaping () -> ()) {
        self.content = content()
        self.onDelete = onDelete
    }
    
    /// Propiedades de la vista.
    @State private var dragProgress: CGFloat = 0
    @State private var isExpanded: Bool = false
    
    var body: some View {
        content
            .hidden()
            .overlay(content: {
                GeometryReader {
                    let rect = $0.frame(in: .global)
                    let minX = rect.minX
                    
                    /// Sustitúyalo como vista de fondo.
                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                        .fill(.red.gradient)
                        .overlay(alignment: .trailing) {
                            Button {
                                /// Removing Card Completely
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7)) {
                                    dragProgress = 1
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                    onDelete()
                                }
                            } label: {
                                Image(systemName: "trash")
                                    .font(.title)
                                    .fontWeight(.semibold)
                                    .padding(.trailing, 20)
                                    .foregroundColor(.white)
                                    .contentShape(Rectangle())
                            }
                            .disabled(!isExpanded)

                        }
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                        .gesture(
                            DragGesture()
                                .onChanged({ value in
                                    /// Desactivar el gesto cuando está expandido.
                                    guard !isExpanded else { return }
                                    /// Deslizamiento de derecha a izquierda: Valor negativo.
                                    var translationX = value.translation.width
                                    /// Limitación al máximo cero.
                                    translationX = max(-translationX, 0)
                                    /// Conversión de la translacion en progreso (0 - 1).
                                    let progress = min(1, translationX / rect.width)
                                    dragProgress = progress
                                }).onEnded({ value in
                                    /// Desactivar el gesto cuando está expandido.
                                    guard !isExpanded else { return }
                                    /// Final suave Animación.
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7)) {
                                        if dragProgress > 0.25 {
                                            dragProgress = 0.6
                                            isExpanded = true
                                        } else {
                                            dragProgress = .zero
                                            isExpanded = false
                                        }
                                    }
                                })
                        )
                    /// Si pulsamos otro botón que no sea el de borrar, volverá al estado inicial.
                        .onTapGesture {
                            withAnimation(.spring(response: 0.6,dampingFraction: 0.7, blendDuration: 0.7)) {
                                dragProgress = .zero
                                isExpanded = false
                            }
                        }
                    
                    /// Sombra.
                    Rectangle()
                        .fill(.black)
                        .padding(.vertical, 23)
                        .shadow(color: .black.opacity(0.3), radius: 15, x: 30, y: 0)
                        /// Moverse a lo largo del lado mientras se arrastra.
                        /// Para que la sombra sea visible, desplaza el rectángulo a medida que avanza el gesto.
                        .padding(.trailing, rect.width * dragProgress)
                        .mask(content)
                        /// Desactiva interacción.
                        .allowsHitTesting(false)
                        .offset(x: dragProgress == 1 ? -minX : 0)
                    
                    content
                        .mask {
                            Rectangle()
                            /// Enmascarar el contenido original.
                            /// Deslízate: De derecha a izquierda.
                            /// Así se enmascara de derecha a izquierda (trailing).
                            /// Cuando el usuario empieza a arrastrar, el contenido empieza a ocultarse de derecha a izquierda, por eso aplicamos relleno en la parte final.
                                .padding(.trailing, dragProgress * rect.width)
                        }
                        /// Desactiva la interacción.
                        .allowsHitTesting(false)
                        .offset(x: dragProgress == 1 ? -minX : 0)
                }
            })
            .overlay {
                GeometryReader {
                    let size = $0.size
                    let minX = $0.frame(in: .global).minX
                    content
                        /// Haciendo que parezca que está rodando.
                        /// Hemos utilizado el gesto para obtener la funcionalidad principal, el efecto de pelado, y ahora vamos a añadir sombra, resplandor, degradados y otros elementos para que parezca que se está pelando.
                        .shadow(color: .black.opacity(dragProgress != 0 ? 0.1 : 0), radius: 5, x: 15, y: 0)
                        .overlay {
                            Rectangle()
                                .fill(.white.opacity(0.25))
                                .mask(content)
                        }
                        /// Haciendo que brille en la parte trasera.
//                        .overlay {
//                            Rectangle()
//                                .fill(
//                                    .LinearGradient(colors: [
//                                        .clear,
//                                        .white,
//                                        .clear,
//                                        .clear
//                                    ], startPoint: .leading, endPoint: .trailing)
//                                )
//                        }
                        /// Voltea horizontalmente para obtener la imagen es efecto espejo.
                        /// ¿POR QUÉ VOLTEAR?
                        /// Como el enmascaramiento comienza de derecha a izquierda, volteamos la superposición horizontalmente para que coincida con el efecto de enmascaramiento.
                        .scaleEffect(x: -1)
                        .contentShape(Rectangle())
                        /// Como colocamos una superposición, el enmascaramiento no es visible, por lo que tenemos que desplazar la superposición hasta su extremo derecho y movernos junto con el progreso del gesto.  Esto nos permite ver tanto el enmascaramiento como la superposición.
                        /// Desplazarse lateralmente mientras se arrastra .
                        .offset(x: size.width - (size.width * dragProgress))
                        /// Al desplazar la superposición, ésta se moverá más rápidamente que el efecto de enmascaramiento predeterminado.
                        .offset(x: size.width * -dragProgress)
                        /// Máscara Imagen superpuesta para eliminar la visibilidad hacia el exterior.
                        .mask {
                            Rectangle()
                                /// Cubrir la región de overscrolling.
                                /// ¡BUM! Usted puede ver que parece ser pelling apagado en este momento.
                                .offset(x: size.width * -dragProgress)
                        }
                        .offset(x: dragProgress == 1 ? -minX : 0)
                }
                /// Desactivando interacción.
                .allowsHitTesting(false)
            }
    }
}

struct PeelEffect_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
