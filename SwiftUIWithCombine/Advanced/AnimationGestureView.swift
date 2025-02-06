//
//  AnimationGestureView.swift
//  SwiftUIWithCombine
//
//  Created by Tang Tango on 2025/1/24.
//

import SwiftUI

// MARK: - 自定义动画视图
struct AnimatedCard: View {
    let title: String
    @State private var isFlipped = false
    @State private var degree = 0.0

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(isFlipped ? .blue : .green)
                .frame(width: 200, height: 120)
                .shadow(radius: 5)

            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
        }
        .rotation3DEffect(
            .degrees(degree),
            axis: (x: 0.0, y: 1.0, z: 0.0)
        )
        .onTapGesture {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                degree += 180
                isFlipped.toggle()
            }
        }
    }
}

struct AnimationGestureView: View {
    // MARK: - Properties
    @State private var offset = CGSize.zero
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0.0
    @State private var isAnimating = false

    // MARK: - Gesture State
    @GestureState private var dragState = CGSize.zero
    @GestureState private var rotationState = Angle.zero
    @GestureState private var scaleState: CGFloat = 1.0

    // MARK: - Gestures
    var dragGesture: some Gesture {
        DragGesture()
            .updating($dragState) { value, state, _ in
                state = value.translation
            }
            .onEnded { value in
                withAnimation {
                    offset = CGSize(
                        width: offset.width + value.translation.width,
                        height: offset.height + value.translation.height
                    )
                }
            }
    }

    var rotationGesture: some Gesture {
        RotationGesture()
            .updating($rotationState) { value, state, _ in
                state = value
            }
            .onEnded { value in
                withAnimation {
                    rotation += value.degrees
                }
            }
    }

    var scaleGesture: some Gesture {
        MagnificationGesture()
            .updating($scaleState) { value, state, _ in
                state = value
            }
            .onEnded { value in
                withAnimation {
                    scale *= value
                }
            }
    }

    // MARK: - Combined Gesture
    var combinedGesture: some Gesture {
        dragGesture.simultaneously(with: rotationGesture.simultaneously(with: scaleGesture))
    }

    var body: some View {
        VStack(spacing: 30) {
            // 基础动画示例
            Section {
                Text("基础动画")
                    .font(.headline)

                Button("触发动画") {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                        isAnimating.toggle()
                    }
                }

                Circle()
                    .fill(.blue)
                    .frame(width: 100, height: 100)
                    .scaleEffect(isAnimating ? 1.5 : 1.0)
                    .opacity(isAnimating ? 0.5 : 1.0)
            }

            // 3D 翻转动画
            Section {
                Text("3D 翻转")
                    .font(.headline)

                AnimatedCard(title: "点击翻转")
            }

            // 手势交互
            Section {
                Text("手势交互")
                    .font(.headline)

                RoundedRectangle(cornerRadius: 12)
                    .fill(.green)
                    .frame(width: 200, height: 200)
                    .scaleEffect(scale * scaleState)
                    .rotationEffect(Angle.degrees(rotation) + rotationState)
                    .offset(x: offset.width + dragState.width, y: offset.height + dragState.height)
                    .gesture(combinedGesture)
            }
        }
        .padding()
        .navigationTitle("动画与手势")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationView {
        AnimationGestureView()
    }
}
