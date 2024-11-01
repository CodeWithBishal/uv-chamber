# Chromatogram
It is a android app that takes image from a IOT based device using websockets 
sends it to the server or cloud and runs python scripts and returns the output to the APP


Images           |  Images
:-------------------------:|:-------------------------:
![86c3476f-3d1e-4d98-beb4-9965aa65e832](https://github.com/dhruvpatidar359/chamber/assets/103873587/6ef5b0c1-1cfc-4c07-b0c1-9836bb8c6a30) |![8b3abec3-1ce8-481a-9db3-4e84fe5df48c](https://github.com/dhruvpatidar359/chamber/assets/103873587/219e849f-214b-4266-a51d-745c26cf2f18)

Images           |  Images
:-------------------------:|:-------------------------:
![WhatsApp Image 2024-02-03 at 5 10 18 PM](https://github.com/dhruvpatidar359/chamber/assets/103873587/2088fa74-01d5-4ad8-b85d-3025e19f4427) |![WhatsApp Image 2024-02-03 at 5 10 17 PM](https://github.com/dhruvpatidar359/chamber/assets/103873587/af437f82-f835-4e08-a552-e444c6dc7956)

# Setup
## Prerequisite
1) Download and install opencv 4.9.0_5
- For MacOS, use: https://formulae.brew.sh/formula/opencv
2) Download and install cmake
- For MacOS, use: https://formulae.brew.sh/formula/cmake

## Folders
- lib/opencv-cpp contains all the cpp code responsible for calculating TLC

## Files
- lib/features/imageManipulation/image_crop.dart
```
void calculateTLC(CroppedFile croppedFile) {
    final imagePath = croppedFile.path.toNativeUtf8();
    final imageFfi = dylib.lookupFunction<Void Function(Pointer<Utf8>),
        void Function(Pointer<Utf8>)>('detect_contour_tlc');
    imageFfi(imagePath);
    setState(() {
      _processedImage = File(imagePath.toDartString());
    });
    saveImage(imagePath.toDartString());
  }
```
This function is used to connect with dart ffi
