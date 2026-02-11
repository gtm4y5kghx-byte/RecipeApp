import SwiftUI
import PhotosUI

struct RecipeFormImage: View {
    @Binding var selectedImageData: Data?
    let hasImage: Bool
    let onRemove: () -> Void
    
    @State private var selectedItem: PhotosPickerItem?
    
    var body: some View {
        Group {
            if let imageData = selectedImageData,
               let uiImage = UIImage(data: imageData) {

                VStack(spacing: Theme.Spacing.sm) {
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                            .cornerRadius(Theme.CornerRadius.md)

                        Button {
                            onRemove()
                            selectedItem = nil
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.white)
                                .shadow(radius: 2)
                        }
                        .padding(Theme.Spacing.sm)
                    }

                    PhotosPicker(
                        selection: $selectedItem,
                        matching: .images,
                        photoLibrary: .shared()
                    ) {
                        DSLabel("Change Photo", style: .subheadline, color: .accent)
                    }
                }
            } else {
                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    VStack(spacing: Theme.Spacing.md) {
                        Image(systemName: "camera")
                            .font(.system(size: 32))
                            .foregroundStyle(Theme.Colors.textSecondary)

                        DSLabel("Add Photo", style: .subheadline, color: .secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 120)
                    .background(
                        RoundedRectangle(cornerRadius: Theme.CornerRadius.md)
                            .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8]))
                            .foregroundStyle(Theme.Colors.textSecondary.opacity(0.5))
                    )
                }
            }
        }
        .padding(.horizontal, Theme.Spacing.md)
        .padding(.top, Theme.Spacing.md)
        .padding(.bottom, Theme.Spacing.sm)
        .onChange(of: selectedItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    selectedImageData = data
                }
            }
        }
    }
}
