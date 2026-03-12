# Figma Component Library - Catfish Disease Detector

## 🎨 Component Specifications

---

## 1. Health Status Card

**Frame**: 375px × 240px (Mobile)
**Background**: White
**Border Radius**: 24px
**Border**: 2px, Status Color
**Shadow**: 0px 8px 20px, Status Color 20%

### Layers:
```
├── Background (White)
├── Border (Status Color, 2px)
├── Shadow (Status Color 20%)
├── Content Padding (24px)
│   ├── Status Icon Container
│   │   ├── Size: 56px × 56px
│   │   ├── Radius: 16px
│   │   ├── Background: Status Color Gradient (30% → 10%)
│   │   ├── Border: Status Color 30%, 1px
│   │   └── Icon: 36px, Status Color Emoji
│   ├── Status Info
│   │   ├── Title: "Pond Health Status" (Body Medium, #616161)
│   │   ├── Status: H3, Status Color, Bold
│   │   └── Description: Body Medium, #616161, 1.4 line height
│   └── Progress Section
│       ├── Progress Bar: 12px height, 6px radius
│       ├── Background: Status Color 15%
│       ├── Fill: Status Color Gradient (80% → 100%)
│       └── Health Score: Status Color 10% background, 8px radius
```

---

## 2. Quick Action Button

**Frame**: 160px × 120px
**Background**: Gradient (White → Status Color 5%)
**Border Radius**: 20px
**Border**: 1.5px, Status Color 30%
**Shadow**: 0px 6px 12px, Status Color 20%

### States:
```
Default: Scale 100%, Elevation 6px
Pressed: Scale 95%, Elevation 2px
Hover: Scale 102%, Elevation 8px
```

### Layers:
```
├── Background Gradient
├── Border (Status Color 30%)
├── Shadow (Status Color 20%)
├── Content Padding (20px)
│   ├── Icon Container
│   │   ├── Size: 56px × 56px
│   │   ├── Radius: 16px
│   │   ├── Background: Status Color Gradient (100% → 80%)
│   │   ├── Shadow: Status Color 30%, 0px 4px 8px
│   │   └── Icon: 28px, White
│   └── Label
│       ├── Text: Button Small, Status Color, Medium
│       └── Alignment: Center
```

---

## 3. Detection Card

**Frame**: 343px × 120px (Mobile)
**Background**: White
**Border Radius**: 20px
**Shadow**: 0px 4px 8px, #1A000000

### Animation:
```
Entrance: Slide Up 20px + Fade In (300ms)
Press: Scale 98% (200ms)
```

### Layers:
```
├── Background (White)
├── Shadow (#1A000000)
├── Content Padding (20px)
│   ├── Status Icon Container
│   │   ├── Size: 56px × 56px
│   │   ├── Radius: 16px
│   │   ├── Background: Status Color Gradient (20% → 10%)
│   │   ├── Border: Status Color 30%, 1.5px
│   │   └── Icon: 28px, Status Color Emoji
│   ├── Detection Info
│   │   ├── Disease Name: H4, Bold, #424242
│   │   ├── Confidence Badge
│   │   │   ├── Padding: 10px × 4px
│   │   │   ├── Radius: 12px
│   │   │   ├── Background: Status Color Gradient (15% → 5%)
│   │   │   ├── Border: Status Color 30%, 1px
│   │   │   └── Text: Body Small, Status Color, Bold
│   │   └── Timestamp
│   │       ├── Icon: 14px, #757575
│   │       └── Text: Body Small, #757575
│   └── Arrow Icon
│       ├── Container: 8px padding, 12px radius
│       ├── Background: Status Color 10%
│       └── Icon: 16px, Status Color
```

---

## 4. Live Status Bar

**Frame**: 375px × 100px
**Background**: Gradient (Accent Green → Accent Green 80%)
**Border Radius**: 24px (bottom only)
**Shadow**: 0px 4px 12px, Accent Green 30%

### Layers:
```
├── Background Gradient
├── Shadow (Accent Green 30%)
├── Content Padding (20px)
│   ├── Live Indicator
│   │   ├── Container: 8px padding, 12px radius
│   │   ├── Background: White
│   │   ├── Red Dot: 8px × 8px, Animated Pulse
│   │   └── Text: "LIVE", 10px, Red, Bold
│   ├── Status Info
│   │   ├── Title: H4, White, Bold
│   │   └── Description: Body Medium, White 90%
│   └── Detection Count
│       ├── Container: 16px padding, 8px vertical, 20px radius
│       ├── Background: White 20%
│       ├── Border: White 30%, 1px
│       ├── Icon: 16px, White
│       └── Count: 14px, White, Bold
```

---

## 5. Alert Card

**Frame**: 343px × 100px
**Background**: White
**Border Radius**: 16px
**Shadow**: 0px 4px 8px, #1A000000

### Severity Variants:
```
High: #E53935
Medium: #FF9800
Low: #1976D2
```

### Layers:
```
├── Background (White)
├── Shadow (#1A000000)
├── Content Padding (16px)
│   ├── Severity Icon Container
│   │   ├── Size: 48px × 48px
│   │   ├── Radius: 12px
│   │   ├── Background: Severity Color 20%
│   │   └── Icon: 24px, Severity Color
│   ├── Alert Info
│   │   ├── Title: H4, Bold
│   │   ├── Message: Body Medium
│   │   ├── Severity Badge
│   │   │   ├── Padding: 6px × 2px
│   │   │   ├── Radius: 8px
│   │   │   ├── Background: Severity Color 10%
│   │   │   └── Text: 10px, Severity Color, Bold
│   │   └── Timestamp: Body Small, #757575
│   └── Unread Indicator
│       ├── Size: 8px × 8px
│       ├── Radius: 4px
│       └── Background: Severity Color
```

---

## 6. Disease Info Card

**Frame**: 160px × 200px
**Background**: White
**Border Radius**: 20px
**Shadow**: 0px 4px 8px, Status Color 20%

### Layers:
```
├── Background (White)
├── Shadow (Status Color 20%)
├── Content Padding (20px)
│   ├── Disease Icon Container
│   │   ├── Size: 72px × 72px
│   │   ├── Radius: 20px
│   │   ├── Background: Status Color Gradient (20% → 10%)
│   │   ├── Border: Status Color 30%, 1.5px
│   │   └── Icon: 36px, Status Color
│   ├── Disease Name
│   │   ├── Text: H4, Bold, Text Center
│   │   └── Color: #424242
│   ├── Description
│   │   ├── Text: Body Small, Text Center
│   │   ├── Lines: 3 max
│   │   └── Color: #616161
│   └── Learn More Button
│       ├── Container: 12px padding, 6px vertical, 12px radius
│       ├── Background: Status Color Gradient (10% → 5%)
│       ├── Border: Status Color 30%, 1px
│       ├── Text: Body Small, Status Color, Bold
│       └── Arrow: 12px, Status Color
```

---

## 7. Bottom Navigation

**Frame**: 375px × 80px
**Background**: White
**Shadow**: 0px 12px, #1A000000

### Tab Item (Active):
```
├── Icon: 24px, Primary Blue, Filled
├── Label: 12px, Primary Blue, SemiBold
└── Background: Transparent
```

### Tab Item (Inactive):
```
├── Icon: 24px, Grey, Outlined
├── Label: 12px, Grey, Regular
└── Background: Transparent
```

---

## 🎯 Layout Grid System

### Mobile (375px width):
```
Container Padding: 16px
Content Width: 343px
Grid Columns: 1
Card Spacing: 16px
Section Spacing: 24px
```

### Tablet (768px width):
```
Container Padding: 24px
Content Width: 720px
Grid Columns: 2
Card Spacing: 16px
Section Spacing: 24px
```

### Desktop (1200px width):
```
Container Padding: 32px
Content Width: 1136px
Grid Columns: 3
Card Spacing: 20px
Section Spacing: 32px
```

---

## 🎨 Color Application Rules

### Status Color Mapping:
```
Healthy: #4CAF50 (Green)
Suspicious: #FF9800 (Orange)
Disease: #E53935 (Red)
```

### Opacity Rules:
```
Background Tints: 5%, 10%, 15%, 20%
Borders: 30%, 40%
Shadows: 20%, 30%
Text: 100%, 90%, 80%
```

### Gradient Rules:
```
Status Gradients: Color → Color (80% opacity)
Background Gradients: White → Color (5% opacity)
Button Gradients: Color → Color (80% opacity)
```

---

## 📐 Spacing Matrix

### Component Padding:
```
Cards: 24px
Buttons: 24px × 16px
Icons: 16px
Badges: 8px × 4px
Navigation: 20px
```

### Component Margins:
```
Cards: 16px bottom
Sections: 24px bottom
Grid Items: 16px
Screen Edges: 16px (Mobile), 24px (Tablet), 32px (Desktop)
```

### Internal Spacing:
```
Text Lines: 8px
Icon-Text: 12px
Button Elements: 6px
Card Elements: 16px
```

---

This Figma component specification provides exact measurements, colors, and layer structures for implementing the Catfish Disease Detector design system with pixel-perfect accuracy.
