# 🌼 PlantApp - Design & Share Your Flower Vase

**PlantApp** is a creative and user-friendly iOS app that allows users to design digital flower arrangements by dragging flowers into a virtual vase. With a clean interface, intuitive gestures, and shareable visuals, this app offers a delightful experience especially for flower lovers, decorators, and casual users who enjoy creative expression.

---

## ✨ Features Overview

🪻 **Drag-and-Drop Flower Arrangement**  
Effortlessly drag and drop flower images into the vase. Each drag creates a visual copy of the flower within the vase frame, allowing you to create a unique floral design.

🔁 **Undo Last Flower**  
Changed your mind? Tap the **Undo** button to remove the last flower added to the vase without disrupting your entire design.

🧹 **Reset Vase**  
Clear your entire vase arrangement with a single tap using the **Reset** button — perfect for starting over or trying a new combination.

📸 **Smart Screenshot Capture**  
Tap **Save**, and the app will automatically capture only the vase and its flowers, excluding all buttons and UI — creating a clean and aesthetic image.

💾 **Save to Photo Library**  
Captured images are saved directly to your Photos app under a custom album named **MyPlantApp**. All necessary photo permissions are handled safely and gracefully.

🚀 **Prepare for Upload**  
Easily forward your latest flower design to the **Upload** tab with one tap. The image is auto-filled, and you can add a caption before sharing.

🌈 **Lottie Animations**  
Polished animations add a smooth and delightful touch to the user experience.

🔐 **Privacy-Respecting**  
All requests for camera roll access use appropriate permissions defined in `Info.plist`, ensuring full compliance with Apple’s privacy requirements.

🧠 **Clean MVC Architecture**  
Designed following Apple’s Model-View-Controller paradigm for clear, maintainable, and scalable code.

---

## 📂 Project Structure

- `FeedViewController.swift`: Manages the user interface and core logic of flower placement.
- `FeedCell.swift`: Custom cell to render flowers.
- `SceneDelegate.swift` & `AppDelegate.swift`: Application lifecycle configuration.
- `GoogleService-Info.plist`: Firebase configuration (optional).
- `Animation.json`: Lottie animation file.

## 📸 How It Works

1. Open the **My Plant** screen.
2. Drag any flower image into the vase. Each flower placed creates a new visual instance.
3. Want to change your design?
   - Tap **Undo** to remove the last flower.
   - Tap **Reset** to clear all.
4. Tap **Save** and choose:
   - **Save to your photos** – Captures only the vase + flowers and stores it.
   - **Prepare for upload** – Sends the design to the Upload screen for sharing.
5. In the **Upload tab**, write a caption and post your flower arrangement (if Firebase is enabled).

## 🧰 Technologies Used

- Swift & UIKit
- Auto Layout for responsive design
- Lottie for animations
- Firebase (for optional cloud integration)
- MVC Design Pattern

## 🖼️ Screenshots

### Main Screen
![Main Screen](![Main Screen](https://github.com/user-attachments/assets/d778b4ce-cfce-48cc-bb46-fd9e7a27445f))

### Create your vase with flower Drag and Drop feauture
![Drag Drop](![My Plant](https://github.com/user-attachments/assets/148bb043-9eb0-40cb-8d53-fd1500530d30))

### Settings 
![Save Options](![Settings](https://github.com/user-attachments/assets/2fd1988c-3b8a-462a-b08b-4b20a53f839c))

### Feed with plant pictures and comments
![Feed]((![Feed](https://github.com/user-attachments/assets/d9dc1d74-7a25-41c2-b27f-3f876eb5ec61)))

### Upload your plants
![Upload]((![Upload](![Upload](https://github.com/user-attachments/assets/57f8e563-e2f3-42fe-b680-958110390902))))




