# Catfish Disease Detector

**AI-Based Image Detection of Catfish Diseases with Real-Time Monitoring for Backyard Farmers**

A clean, simple, and farmer-friendly mobile application designed to help backyard fish farmers monitor catfish health using AI-powered disease detection.

## 🎯 Design Goals

- **Farmer-friendly UI** - Minimal technical knowledge required
- **Clean and modern look** - Professional appearance for thesis presentation
- **Easy to explain during defense** - Clear visual hierarchy and intuitive navigation
- **Focus on readability and simplicity** - Large fonts and clear icons
- **Works well on low-end Android phones** - Optimized performance and responsive design

## 🎨 Design Style

### Color Palette
- **Primary Blue**: `#2196F3` - Main app color, represents water/aquaculture
- **Secondary Teal**: `#00BCD4` - Accent color for secondary actions
- **Success Green**: `#4CAF50` - Healthy status, positive actions
- **Warning Yellow**: `#FF9800` - Suspicious status, caution
- **Danger Red**: `#F44336` - Disease detected, critical alerts
- **Background**: `#F5F9FF` - Light blue tint, clean appearance

### Health Status Colors
- 🟢 **Green** (`#4CAF50`) - Healthy pond
- 🟡 **Yellow** (`#FF9800`) - Suspicious activity
- 🔴 **Red** (`#F44336`) - Disease detected

### Typography
- **Font**: Google Fonts - Poppins
- **Large touch targets**: Minimum 44px for accessibility
- **High contrast**: Ensures outdoor visibility
- **Card-based layout**: Modern, organized information display

## 📱 App Screens

### 1. Dashboard Screen
**Main hub showing pond health at a glance**

Features:
- **Large health status card** with color-coded indicator
- **Latest detection summary** with confidence scores
- **Total alerts counter** for quick awareness
- **Quick navigation buttons** to main features
- **Recent activity feed** showing last 3 detections
- **Online status indicator** for monitoring system

Layout:
- Top: App title + pond name + online status
- Middle: Large status indicator card with health score
- Bottom: Quick action buttons (Monitoring, Alerts, History, Scan)

### 2. Live Monitoring Screen
**Real-time detection feed with live updates**

Features:
- **Live indicator** with animated pulse effect
- **Scrollable detection cards** showing real-time results
- **Auto-refresh functionality** every 5 seconds
- **Pause/Resume monitoring** control
- **Detection count display**
- **Detailed detection modal** on tap

Each detection card includes:
- Disease name with confidence percentage
- Timestamp with relative time
- Status emoji indicator
- Small image preview placeholder
- Confidence score badge

### 3. Detection Details Screen
**Comprehensive view of individual detections**

Features:
- **Full captured image display**
- **Disease classification** with confidence score
- **Time detected** with full date/time
- **Suggested action card** with recommendations
- **Detection metadata** (ID, status, etc.)
- **Scientific presentation layout** for thesis defense

### 4. Alerts Screen
**Centralized alert management system**

Features:
- **Alert summary cards** showing critical/warning/info counts
- **Color-coded severity levels** (High/Medium/Low)
- **Unread indicator dots** for new alerts
- **Mark all as read** functionality
- **Alert details dialog** with full information
- **Filter options** for alert types

Alert types:
- 🔴 **Critical**: Disease detected, immediate action required
- 🟡 **Warning**: Suspicious activity, monitoring needed
- 🔵 **Info**: System notifications, general updates

### 5. Detection History Screen
**Comprehensive historical data with filtering**

Features:
- **Filter by date range** with date picker
- **Filter by disease type** (All, Healthy, Suspicious, Disease, or specific diseases)
- **Statistics cards** showing total detections and disease cases
- **Clear filters option**
- **Detailed detection information** on tap
- **Research-friendly layout** for thesis analysis

Filter options:
- By date range (custom date picker)
- By disease type (Columnaris, Aeromonas, White Spot, etc.)
- By health status (Healthy, Suspicious, Disease)

### 6. Disease Information Screen
**Educational resource for farmers**

Features:
- **5 common catfish diseases** with detailed information
- **Icon-based layout** for easy recognition
- **Comprehensive disease pages** including:
  - Symptoms (visual signs to watch for)
  - Causes (underlying factors)
  - Treatment (recommended actions)
  - Prevention (proactive measures)

Diseases covered:
1. **Columnaris** - Bacterial infection with cotton-like growth
2. **Aeromonas** - Hemorrhagic septicemia and ulcers
3. **White Spot (Ich)** - Protozoan parasite with white spots
4. **Fungal Infection** - Cotton wool-like fungal growth
5. **Fin Rot** - Progressive fin deterioration

## 🧭 Navigation System

**Bottom Navigation Bar** - Simple and intuitive:
- **Dashboard** - Main overview screen
- **Monitor** - Live detection feed
- **Alerts** - Alert management
- **Diseases** - Educational information

Navigation features:
- **Active state indicators** with filled icons
- **Minimal labels** for clarity
- **Large touch targets** for outdoor use
- **Consistent placement** following mobile conventions

## 👨‍🌾 User Experience Considerations

### Accessibility
- **Large touch targets** (minimum 44px)
- **High contrast colors** for outdoor visibility
- **Clear, readable fonts** with appropriate sizing
- **Simple English labels** (Filipino-friendly structure)

### Performance
- **Optimized for low-end devices** - Minimal animations
- **Efficient state management** with Provider pattern
- **Responsive design** works on all screen sizes
- **Offline capability** for basic functionality

### Farmer-Friendly Features
- **Minimal text** - More visual indicators
- **Clear icons** with universal meanings
- **Color-coded health status** for quick understanding
- **Simple navigation** - No complex menus
- **Large buttons** for easy outdoor use

## 🎓 Thesis Presentation Ready

### Professional Features
- **Clean, scientific layout** suitable for academic presentation
- **Clear demonstration of real-time monitoring capabilities**
- **Easy to explain UI components** to defense panel
- **Visual hierarchy** supports presentation flow
- **Consistent design language** throughout app

### Key Talking Points
1. **Real-time AI monitoring** - Live detection feed demonstrates continuous monitoring
2. **Farmer-centric design** - Simple interface shows consideration for end users
3. **Comprehensive disease database** - Educational component adds value
4. **Alert system** - Proactive approach to disease management
5. **Historical data analysis** - Research capabilities for thesis analysis

## 🛠 Technical Implementation

### Architecture
- **Flutter framework** for cross-platform compatibility
- **Provider state management** for efficient data handling
- **Material Design 3** for modern, consistent UI
- **Responsive design** for various screen sizes

### Key Components
- **Modular widget structure** for maintainability
- **Theme system** for consistent styling
- **Data models** for structured information
- **Sample data generation** for demonstration

### Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  google_fonts: ^6.1.0
  intl: ^0.18.1
  provider: ^6.1.1
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Android Studio or VS Code
- Android emulator or physical device

### Installation
1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Connect device or start emulator
4. Run `flutter run` to start the app

### Project Structure
```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   └── detection_data.dart   # Detection and alert models
├── screens/                  # App screens
│   ├── dashboard_screen.dart
│   ├── monitoring_screen.dart
│   ├── alerts_screen.dart
│   ├── history_screen.dart
│   └── disease_info_screen.dart
├── widgets/                  # Reusable components
│   ├── health_status_card.dart
│   ├── quick_action_button.dart
│   ├── detection_summary_card.dart
│   ├── detection_card.dart
│   └── live_indicator.dart
└── theme/                    # App theming
    └── app_theme.dart        # Colors, fonts, and styles
```

## 📋 Features Checklist

- [x] Dashboard with pond health status
- [x] Live monitoring with real-time updates
- [x] Alert management system
- [x] Detection history with filtering
- [x] Disease information database
- [x] Bottom navigation
- [x] Theme system with aquaculture colors
- [x] Sample data for demonstration
- [x] Responsive design
- [x] Farmer-friendly interface

## 🎯 Future Enhancements

- **Camera integration** for real-time fish scanning
- **Push notifications** for critical alerts
- **Data export** functionality for research
- **Multi-pond support** for larger operations
- **Offline mode** with data synchronization
- **Filipino language** support
- **Voice guidance** for accessibility

## 📞 Contact

This project was designed for thesis presentation purposes, focusing on clean UI/UX design and farmer-friendly interfaces for aquaculture disease monitoring.

---

**Note**: This is a UI demonstration project. The AI detection functionality is simulated with sample data for presentation purposes.
