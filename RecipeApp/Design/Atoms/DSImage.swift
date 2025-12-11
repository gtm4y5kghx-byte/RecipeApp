import SwiftUI

struct DSImage: View {

      let url: String?
      let height: CGFloat?
      let aspectRatio: ContentMode

      init(
          url: String?,
          height: CGFloat? = nil,
          aspectRatio: ContentMode = .fill
      ) {
          self.url = url
          self.height = height
          self.aspectRatio = aspectRatio
      }

      var body: some View {
          if let url = url, let imageURL = URL(string: url) {
              AsyncImage(url: imageURL) { phase in
                  switch phase {
                  case .empty:
                      placeholder
                          .overlay { ProgressView() }
                  case .success(let image):
                      image
                          .resizable()
                          .aspectRatio(contentMode: aspectRatio)
                  case .failure:
                      placeholder
                          .overlay {
                              DSIcon("photo", size: .xlarge, color: .tertiary)
                          }
                  @unknown default:
                      EmptyView()
                  }
              }
          } else {
              placeholder
                  .overlay {
                      DSIcon("photo", size: .xlarge, color: .tertiary)
                  }
          }
      }

      private var placeholder: some View {
          Rectangle()
              .fill(Theme.Colors.backgroundDark)
              .frame(height: height)
      }
  }
