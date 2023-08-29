# Ampel-Pilot

[![Platform](http://img.shields.io/badge/platform-ios-blue.svg?style=flat
)](https://developer.apple.com/iphone/index.action)
[![Language](http://img.shields.io/badge/language-swift-brightgreen.svg?style=flat
)](https://developer.apple.com/swift)
[![License](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat
)](http://mit-license.org)

Pedestrian Traffic Light Detector for visually impaired people, that can be used as guidance for determining the current phase of a pedestrian traffic light.

![Demo GIF](https://github.com/patVlnta/Ampel-Pilot/blob/master/images/ap_demo.gif "Demo GIF Animation")



## Features

* Detection and recognition of pedestrian traffic lights and traffic lights
* Audiovisual and  haptic feedback based on the current pedestrian light phase (Red, Green, Changing) and traffic light phase (Red, Green)
* Accessibility added for easier usage of the app - iPhone haptics, audiovisual cues in the form of the screen turning the color of the pedestrian light and a voice telling user to walk or not
* Option to customize feedback and detection parameters

## Model and Dataset

The model used in the application is trained with the ML framework YOLOv5. Trained on 1300 images created using an original curated dataset which was then preprocessed and augmented:

mAP : 74.4%
Precision : 59.7%
Recall : 73.4%

The model is trained to identify all colors in RGB spectrum



* [Dataset repository](https://github.com/patVlnta/Ampel-Pilot-Dataset)
* [LightsCatcher (Android)](https://play.google.com/store/apps/details?id=com.hs_augsburg_example.lightscatcher&hl=en)
* [LightsCatcher (iOS)](https://itunes.apple.com/de/app/lightscatcher/id1227218052?mt=8)

## Details
* The application uses a UIKit Model-View-Controller approach (MVC)
* The main "cycle" of the application occurs with DetectionViewModel / DetectionViewController and the YOLO.swift file
* If one switches to change the model, simply change the "let model = CrossBudV3()" line in YOLO.swift to a working MLModel file
* A link to a PPT detailing the application can be found in the repo

## Limitations

* Model trained largely on pictures of lights not taken from human perspective and distance
* Using the app at night will get you less accurate results due to bloom
* App currently suffers from perfomance glitches and frame drops
* Currently, the app is not removing inaccurate boxes and is therefore clogging the pipeline with hundreds of boxes causing further performance issues 

## Requirements

* Xcode 8 or higher
* iOS 15 or higher

## Contributions

PR´s and/or contributions to the dataset are always very welcome. If you have any further questions, ideas or enquiries, feel free to get in contact either by opening an issue or email [aadishiv@outlook.com](mailto:aadishiv@outlook.com).

## Credits

* Inspired by **hollance´s** [YOLO-CoreML-MPSNNGraph](https://github.com/hollance/YOLO-CoreML-MPSNNGraph)
* **pjreddie** and all contributors for [YOLO/darknet](https://github.com/pjreddie/darknet)
* Original project team [@Hochschule Augsburg](https://www.hs-augsburg.de/Informatik/Ampel-Pilot.html)
* Original dataset contribution [@University of Tuebingen](https://www.uni-tuebingen.de/en/university.html)
