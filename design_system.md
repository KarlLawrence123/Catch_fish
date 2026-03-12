# Catfish Disease Detector - Aquatic Theme Design System

## � Aquatic Theme Concept

### Light Mode - "Surface of Water"
**Inspiration**: Bright, sunny day on calm water surface
**Feeling**: Fresh, clean, optimistic
**Visual Metaphor**: Looking down at clear water from above

### Dark Mode - "Deep Blue Sea"
**Inspiration**: Deep ocean exploration, underwater atmosphere
**Feeling**: Professional, focused, immersive
**Visual Metaphor**: Diving into the depths for detailed analysis

---

## 🎨 Color Palette

### Light Mode - Surface of Water Theme
```
Primary Blue: #0277BD      // Deep water blue
Secondary Teal: #00ACC1    // Light blue reflections
Accent Teal: #26A69A      // Teal accent
Background: #E1F5FE        // Light sky blue (water surface)
Surface: #FFFFFF             // White foam/bubbles
Card: #FFFFFF               // White water foam
Text Primary: #0D47A1       // Deep water text
Text Secondary: #0277BD      // Primary blue text
Text Tertiary: #616161        // Muted text
```

### Dark Mode - Deep Blue Sea Theme
```
Primary Blue: #0D47A1      // Deep ocean blue
Secondary Blue: #01579B     // Darker blue depths
Accent Teal: #00838F       // Deep sea teal
Background: #0A1929        // Deep ocean depths
Surface: #1A237E           // Dark water surface
Card: #283593              // Underwater cave
Text Primary: #FFFFFF        // White text
Text Secondary: #E3F2FD     // Light blue text
Text Tertiary: #90CAF9       // Soft blue text
```

### Status Colors (Universal)
```
Healthy Green: #4CAF50      // Lush underwater plants
Warning Orange: #FF9800     // Sunset warning
Danger Red: #E53935        // Emergency alert
```

### Aquatic Gradients
```
Light Mode Water:
- Start: #B3E5FC (Light water ripples)
- End: #81D4FA (Deeper water)

Dark Mode Water:
- Start: #1E88E5 (Dark water surface)
- End: #1565C0 (Deep ocean)

Status Gradients:
- Light: Color + 15% → 5% opacity
- Dark: Color + 20% → 8% opacity
```

### Shadow System
```
Light Mode Water Shadows: #290277BD (15% opacity)
Dark Mode Water Shadows: #4D0D47A1 (30% opacity)
Universal Shadow: #1A000000 (10% opacity)
```

---

## 📏 Spacing System

### Base Unit: 4px
```
xs: 4px    (0.25rem) - Small bubbles
sm: 8px    (0.5rem)  - Wave spacing
md: 16px   (1rem)    - Card padding
lg: 24px   (1.5rem)  - Section spacing
xl: 32px   (2rem)    - Large gaps
xxl: 48px  (3rem)    - Hero spacing
```

### Aquatic Spacing Rules
```
Card Padding: 24px (like water ripples)
Button Padding: 24px × 16px (touch targets)
Icon Padding: 16px (bubble spacing)
Section Gap: 24px (wave separation)
Element Gap: 16px (current spacing)
Text Gap: 8px (ripple distance)
Micro Gap: 4px (small bubbles)
```

---

## 🔤 Typography

### Font Family: Poppins (Clean, modern, aquatic-friendly)

### Light Mode Typography
```
H1 - 32px / Bold / #0D47A1 (Deep water)
H2 - 24px / SemiBold / #0277BD (Primary blue)
H3 - 20px / SemiBold / #0288D1 (Lighter blue)
H4 - 18px / Medium / #0D47A1 (Deep water)

Body Large - 16px / Regular / #424242
Body Medium - 14px / Regular / #616161
Body Small - 12px / Regular / #757575

Button Large - 16px / Medium / White
Button Medium - 14px / Medium / White
Button Small - 12px / Medium / White
```

### Dark Mode Typography
```
H1 - 32px / Bold / #FFFFFF (White foam)
H2 - 24px / SemiBold / #FFFFFF (White foam)
H3 - 20px / SemiBold / #E3F2FD (Light blue)
H4 - 18px / Medium / #FFFFFF (White foam)

Body Large - 16px / Regular / #B3E5FC (Light blue)
Body Medium - 14px / Regular / #90CAF9 (Soft blue)
Body Small - 12px / Regular / #64B5F6 (Muted blue)

Button Large - 16px / Medium / White
Button Medium - 14px / Medium / White
Button Small - 12px / Medium / White
```

---

## 🎯 Aquatic Components

### 1. Water Surface Header
```
Component: WaterHeader
Height: 64px
Background: Semi-transparent water gradient
Border Radius: 20px (bottom only)
Shadow: Water-tinted shadow
Animation: Gentle wave effect
```

### 2. Health Status Card
```
Component: HealthStatusCard
Width: 100%
Background: Light: White foam / Dark: Underwater cave
Border: Status color with water opacity
Shadow: Water-tinted shadow
Progress Bar: Animated fill like water level
```

### 3. Bubble Button
```
Component: BubbleButton
Background: Water gradient with transparency
Border: Water ripple effect
Shadow: Underwater shadow
Press Animation: Bubble compression effect
```

### 4. Detection Card
```
Component: DetectionCard
Background: Light: White foam / Dark: Underwater cave
Border: Water-tinted border
Shadow: Deep water shadow
Icon Container: Water gradient background
```

### 5. Live Status Bar
```
Component: LiveStatusBar
Background: Water gradient (animated)
Text: White foam color
Shadow: Deep water shadow
Live Indicator: Pulsing bubble effect
```

---

## 🌊 Theme Switching Animation

### Transition Effects
```
Duration: 300ms (gentle wave transition)
Easing: Curves.easeInOut (smooth water flow)
Animation: Cross-fade with scale transform
```

### Theme Toggle Button
```
Light Mode Icon: dark_mode (moon/sun icon)
Dark Mode Icon: light_mode (sun/moon icon)
Background: Water gradient with transparency
Border: Ripple effect
Press Animation: Bubble pop effect
```

---

## 📱 Responsive Water Behavior

### Mobile (< 768px)
```
- Single column layout
- 16px screen padding
- Full-width cards (like floating on water)
- Bottom navigation (underwater bar)
```

### Tablet (768px - 1024px)
```
- Two column grid
- 24px screen padding
- Cards with max width (like lily pads)
- Bottom navigation visible
```

### Desktop (> 1024px)
```
- Three column grid
- 32px screen padding
- Fixed width cards (like organized buoys)
- Side navigation optional
```

---

## 🎭 Animation System

### Aquatic Animations
```
Duration:
- Fast: 150ms (quick bubble)
- Normal: 200ms (gentle wave)
- Slow: 300ms (deep dive)
- Page: 500ms (ocean transition)

Easing:
- Wave: cubic-bezier(0.4, 0.0, 0.2, 1)
- Bubble: cubic-bezier(0.68, -0.55, 0.265, 1.55)
- Current: cubic-bezier(0.0, 0.0, 0.2, 1)
```

### Animation Types
```
Card Entrance: Rise from water (slide up + fade)
Button Press: Bubble compression (scale down)
Live Indicator: Gentle pulse (breathing effect)
Progress Bar: Water level rise (fill animation)
Theme Switch: Dive/Surface transition
```

---

## 🧩 Aquatic Iconography

### Water-Themed Icons
```
Sizes:
- Small: 16px (tiny bubbles)
- Medium: 24px (standard)
- Large: 32px (large buoys)
- Extra Large: 48px (hero elements)

Colors:
- Light Mode: Deep water blues
- Dark Mode: White foam and light blues
- Status: Universal (green, orange, red)
```

---

## 🔲 Aquatic Border Radius

```
Bubble: 50% (perfect circles)
Small: 8px (tiny bubbles)
Medium: 12px (small ripples)
Large: 16px (medium waves)
Extra Large: 20px (large swells)
Round: 24px (gentle curves)
```

---

## 🌊 Visual Effects

### Light Mode Effects
```
- Subtle water ripples on hover
- Soft shadows like cloud reflections
- Bright, optimistic colors
- Clean, spacious layout
- Foam-like white surfaces
```

### Dark Mode Effects
```
- Deep water shadows
- Underwater cave feeling
- Immersive, focused colors
- Compact, efficient layout
- Bioluminescent accents
```

---

This aquatic design system creates a cohesive water-themed experience that naturally transitions between the bright, optimistic "surface of water" light mode and the focused, immersive "deep blue sea" dark mode, perfect for both farmers using the app outdoors and professionals presenting the thesis.
