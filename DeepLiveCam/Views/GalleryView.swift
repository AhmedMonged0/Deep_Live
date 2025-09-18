import SwiftUI
import Photos
import PhotosUI

struct GalleryView: View {
    @StateObject private var photoLibrary = PhotoLibraryManager()
    @State private var selectedImage: UIImage?
    @State private var showingImagePicker = false
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                if photoLibrary.images.isEmpty {
                    EmptyGalleryView()
                } else {
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                            ForEach(photoLibrary.images, id: \.id) { image in
                                GalleryImageCell(
                                    image: image,
                                    isSelected: selectedImage?.cgImage == image.image.cgImage
                                ) {
                                    selectedImage = image.image
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Gallery")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add Photo") {
                        showingImagePicker = true
                    }
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(selectedImage: $selectedImage)
            }
            .onAppear {
                photoLibrary.requestAccess()
            }
        }
    }
}

struct EmptyGalleryView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Photos Yet")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text("Add some photos to get started with face swapping")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding()
    }
}

struct GalleryImageCell: View {
    let image: GalleryImage
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Image(uiImage: image.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 100)
                .clipped()
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                )
                .overlay(
                    Group {
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                                .background(Color.white)
                                .clipShape(Circle())
                                .offset(x: 40, y: -40)
                        }
                    }
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

class PhotoLibraryManager: ObservableObject {
    @Published var images: [GalleryImage] = []
    @Published var isAuthorized = false
    
    private let imageManager = PHImageManager.default()
    
    func requestAccess() {
        PHPhotoLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                self.isAuthorized = status == .authorized || status == .limited
                if self.isAuthorized {
                    self.loadImages()
                }
            }
        }
    }
    
    private func loadImages() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 100
        
        let assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        var loadedImages: [GalleryImage] = []
        
        assets.enumerateObjects { asset, _, _ in
            let requestOptions = PHImageRequestOptions()
            requestOptions.isSynchronous = true
            requestOptions.deliveryMode = .highQualityFormat
            
            self.imageManager.requestImage(
                for: asset,
                targetSize: CGSize(width: 200, height: 200),
                contentMode: .aspectFill,
                options: requestOptions
            ) { image, _ in
                if let image = image {
                    let galleryImage = GalleryImage(
                        id: asset.localIdentifier,
                        image: image,
                        creationDate: asset.creationDate
                    )
                    loadedImages.append(galleryImage)
                }
            }
        }
        
        DispatchQueue.main.async {
            self.images = loadedImages
        }
    }
}

struct GalleryImage: Identifiable {
    let id: String
    let image: UIImage
    let creationDate: Date?
}

#Preview {
    GalleryView(isPresented: .constant(true))
}
