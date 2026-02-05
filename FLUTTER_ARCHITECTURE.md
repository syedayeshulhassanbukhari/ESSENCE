# ESSENCE - Neo-Brutalism Perfume Marketplace

A modern Flutter web application showcasing a neo-brutalism design system with state management using Provider.

## 🎨 Design System

### Neo-Brutalism Architecture
- **Sharp Edges**: No border radius (0px) for aggressive typography
- **Bold Shadows**: Offset shadows (4px, 6px) without blur for dimensional effect
- **High Contrast**: Black/White primary + Vibrant accent colors
- **Typography**: Space Grotesk font family for all text

### Color Palette

| Color | Hex | Usage |
|-------|-----|-------|
| Primary Yellow | #FFFF00 | CTAs, highlights |
| Accent Pink | #FF00FF | Secondary elements |
| Accent Cyan | #00F0FF | Tertiary accents |
| Accent Green | #00FF66 | Quaternary accents |
| Black | #000000 | Text, borders (light mode) |
| White | #FFFFFF | Text, borders (dark mode) |
| Background Light | #FFFFFF | Light mode bg |
| Background Dark | #121212 | Dark mode bg |

### Spacing Scale
- `spacing2` = 8px
- `spacing4` = 16px
- `spacing6` = 24px
- `spacing8` = 32px
- `spacing12` = 48px

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point with Provider setup
├── theme/
│   └── app_theme.dart       # Theme definitions & design tokens
├── providers/
│   └── theme_provider.dart  # Dark/light mode state management
├── widgets/
│   ├── neo_widgets.dart     # Reusable neo-brutalist components
│   └── layout_widgets.dart  # Header, Footer, Layout utilities
├── screens/
│   ├── home_screen.dart     # Discover page with hero & products
│   ├── auth_screen.dart     # Login/Register with email & OAuth
│   └── marketplace_screen.dart  # Filterable product catalog
```

## 🧩 Reusable Components

### NeoButton
Neo-brutalist button with offset shadow on hover/press animation.

```dart
NeoButton(
  label: 'Shop Now',
  onPressed: () {},
  backgroundColor: AppTheme.primaryYellow,
  textColor: AppTheme.black,
  isFullWidth: true,
)
```

### NeoCard
Container with neo border and optional shadow.

```dart
NeoCard(
  backgroundColor: AppTheme.white,
  shadow: true,
  child: Text('Content'),
)
```

### NeoInput
Text field with neo border styling.

```dart
NeoInput(
  label: 'Email',
  placeholder: 'your@email.com',
  controller: controller,
  keyboardType: TextInputType.emailAddress,
)
```

### NeoBadge
Small label badge with border.

```dart
NeoBadge(
  label: 'New',
  backgroundColor: AppTheme.primaryYellow,
)
```

### NeoIconButton
Icon button with neo border and shadow.

```dart
NeoIconButton(
  icon: Icons.search,
  onPressed: () {},
)
```

## 🎯 Screens

### Home Screen (Discover)
- Hero section with featured products
- Curated collection grid
- Community vault section
- Newsletter signup
- Marquee ticker for promotions

### Auth Screen
- Email/password login form
- Google OAuth integration ready
- Remember me checkbox
- Forgot password link
- Split layout (image + form on desktop, stacked on mobile)

### Marketplace Screen
- Filterable product grid
- Sidebar filters (category, intensity, price range)
- Sort options
- Product cards with badges
- Responsive grid layout

## 🌓 Dark/Light Mode

Theme switching is managed by `ThemeProvider`:

```dart
Consumer<ThemeProvider>(
  builder: (context, themeProvider, _) {
    themeProvider.toggleDarkMode();
  },
)
```

All colors automatically adapt based on `Theme.of(context).brightness`.

## 📱 Responsive Design

- **Mobile** (<640px): Single column, stacked layout
- **Tablet** (640-1024px): 2-column layout with adjusted spacing
- **Desktop** (>1024px): Full multi-column grid with sidebars

Uses `MediaQuery.of(context).size.width` for breakpoints.

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.10.8+
- Dart 3.10.8+

### Installation

```bash
# Install dependencies
flutter pub get

# Run web app
flutter run -d web

# Build for production
flutter build web --release
```

### State Management

**Provider** is used for:
- Theme toggle (dark/light mode)
- Future: Authentication state
- Future: Cart management
- Future: Product filters

```dart
ChangeNotifierProvider(
  create: (_) => ThemeProvider(),
  child: const ScentSwapApp(),
)
```

## 🎨 Tailwind → Flutter Mapping

| Tailwind | Flutter |
|----------|---------|
| `border-4` | `AppTheme.borderWidth` = 4.0 |
| `shadow-lg` | `AppTheme.neoShadow()` |
| `space-grotesk` | `GoogleFonts.spaceGrotesk()` |
| `text-primary` | `AppTheme.primaryYellow` |
| `gap-4` | `SizedBox(width: AppTheme.spacing4)` |
| `p-4` | `padding: EdgeInsets.all(AppTheme.spacing4)` |
| `rounded-none` | `borderRadius: BorderRadius.zero` |

## 🔧 Customization

### Adding New Colors
Edit `AppTheme` in `lib/theme/app_theme.dart`:
```dart
static const Color newColor = Color(0xFFHHHHHH);
```

### Modifying Spacing
Update constants in `AppTheme` class.

### Creating New Widgets
Extend `neo_widgets.dart` following the neo-brutalist pattern:
1. Define colors using `AppTheme` constants
2. Use `AppTheme.borderWidth` for borders
3. Add `AppTheme.neoShadow()` for depth
4. No border radius

## 📦 Dependencies

- `flutter`: Core framework
- `google_fonts`: Typography
- `provider`: State management
- `firebase_core`: Firebase setup
- `firebase_auth`: Authentication
- `google_sign_in`: OAuth integration

## 🎯 Future Enhancements

- [ ] Complete Firebase authentication
- [ ] Product detail page
- [ ] Shopping cart
- [ ] Product search & advanced filters
- [ ] User reviews & ratings
- [ ] Admin dashboard
- [ ] Inventory management



Built with using Flutter & Neo-Brutalism design principles.
