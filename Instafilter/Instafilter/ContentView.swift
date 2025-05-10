//
//  ContentView.swift
//  Instafilter
//
//  Created by Mariana Montoya on 3/20/25.
//
// pixel by nakals from <a href="https://thenounproject.com/browse/icons/term/pixel/" target="_blank" title="pixel Icons">Noun Project</a> (CC BY 3.0)


import CoreImage
import CoreImage.CIFilterBuiltins
import PhotosUI
import StoreKit
import SwiftUI


struct ContentView: View {
    @State private var processedImage: Image?
    @State private var filterIntensity = 0.5
    @State private var selectedItem: PhotosPickerItem?
    
    @State private var imageSelected = false
    
    @AppStorage("filterCount") var filterCount = 0
    @Environment(\.requestReview) var requestReview
    
    
    @State private var currentFilter: CIFilter = CIFilter.pixellate()
    let context = CIContext()
    
    @State private var showingFilters = false
    
    var body: some View {
        NavigationStack {
            VStack{
                Spacer()
                
                PhotosPicker(selection: $selectedItem) {
                    if let processedImage {
                            processedImage
                            .resizable()
                            .scaledToFit()
                    } else {
                        ContentUnavailableView("No picture", systemImage: "photo.badge.plus", description: Text("Tap to import a photo"))
                    }
                }
                .onChange(of: selectedItem, loadImage)
                
                Spacer()
                if imageSelected {
                    HStack{
                        Text("Intensity:")
                        Slider(value: $filterIntensity)
                            .onChange(of: filterIntensity, applyProcessing)
                    }
                    
                    HStack {
                        Button("Change Filer", action: changeFilter)
                    }
                    
                }
                Spacer()
                
                if let processedImage {
                    ShareLink(item: processedImage, preview: SharePreview("Instafilter Image", image: processedImage))
                }
            }
            .padding([.horizontal, .bottom])
            .navigationTitle("Pixel It")
            .confirmationDialog("Select a filter", isPresented: $showingFilters) {
                Button("Crystalize") { setFilter(CIFilter.crystallize() )}
                Button("Edges") { setFilter(CIFilter.edges() )}
                Button("Guassian Blur") { setFilter(CIFilter.gaussianBlur() )}
                Button("Pixellate") { setFilter(CIFilter.pixellate() )}
                Button("Sepia Tone") { setFilter(CIFilter.sepiaTone() )}
                Button("Unsharp Mask") { setFilter(CIFilter.unsharpMask())}
                Button("Vignette") { setFilter(CIFilter.vignette() )}
                Button("Cancel", role: .cancel) { }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                Color.orange.ignoresSafeArea()
            }
            .toolbarBackground(.black)
            
            
        }
    }
    func changeFilter(){
        showingFilters = true
    }
    
    func loadImage() {
        Task {
            guard let imageData = try await selectedItem?.loadTransferable(type: Data.self) else { return }
            
            guard let inputImage = UIImage(data: imageData) else { return }
            
            let beginImage = CIImage(image: inputImage)
            currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
            applyProcessing()
        }
        imageSelected = true
    }
    func applyProcessing(){
        
        let inputKeys = currentFilter.inputKeys
        
        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey) }
        if inputKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(filterIntensity * 200, forKey: kCIInputRadiusKey) }
        if inputKeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(filterIntensity * 200, forKey: kCIInputScaleKey) }
    
        
        guard let outputImage = currentFilter.outputImage else { return }
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return }
        
        let uiImage = UIImage(cgImage: cgImage)
        processedImage = Image(uiImage: uiImage)
        
    }
    
    func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        loadImage()
        
        filterCount += 1
        
        if filterCount >= 3 {
            requestReview()
        }
    }
}


#Preview {
    ContentView()
}
