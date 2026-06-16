# PPT

This README is a slide-by-slide outline for building a 15+ slide PPT about the ESSENCE (ScentSwap) perfume marketplace. It includes project intro, tech stack, backend services, color theme, and folder structure.

## Deck Name

PPT

## Project Snapshot

ESSENCE (ScentSwap) is a Flutter web marketplace for fragrances that combines neo-brutalism UI with modern backend services. The project includes a customer-facing web app, a Node.js admin panel for exchange listings, and a real-time chat backend for buyer-seller conversations.

## Slide-by-Slide PPT Outline (18 Slides)

1. Title Slide
   - Project name: ESSENCE / ScentSwap
   - Tagline: Neo-brutalism perfume marketplace
   - Team, date, and course/client
2. Introduction (Website Overview)
   - What the site is: fragrance discovery, marketplace, and exchange
   - Primary users: shoppers, sellers, and admins
3. Problem Statement
   - Fragmented fragrance discovery and resale
   - Lack of real-time trust and negotiation
4. Solution and Value Proposition
   - Unified discovery, listing, and chat
   - Fast onboarding and clear UI
5. Target Audience
   - Fragrance enthusiasts
   - Resellers and collectors
   - Boutique brands
6. Core Features
   - Auth (email and Google)
   - Marketplace browsing and filtering
   - Exchange listings and media
   - Real-time chat
7. User Journey (Buyer)
   - Discover product -> view listing -> chat -> exchange
8. User Journey (Seller/Admin)
   - Upload listing -> manage inventory -> respond to chat
9. UI/UX Design Direction
   - Neo-brutalism (sharp edges, bold contrast, heavy typography)
   - Responsive layout for mobile and desktop
10. Color Theme
   - Primary: #FFFF00
   - Accents: #FF00FF, #00F0FF, #00FF66
   - Neutral: #000000, #FFFFFF, #121212
11. Tech Stack (Frontend)
   - Flutter Web, Dart
   - Provider state management
   - Google Fonts, responsive layout helpers
12. Tech Stack (Backend and Services)
   - Firebase Auth and Firestore
   - Supabase Storage for images
   - Node.js admin panel (Express, Multer)
   - Node.js chat backend (Socket.io)
13. System Architecture (High Level)
   - Flutter Web app -> Firebase Auth/Firestore
   - Flutter Web app -> Chat backend (Socket.io)
   - Admin panel -> Firestore and Supabase Storage
14. Data Flow (Listings)
   - Admin creates listing -> image stored in Supabase -> metadata in Firestore
   - Client reads listings from Firestore
15. Data Flow (Chat)
   - User auth token -> chat backend verifies -> join room -> messages saved
16. Folder Structure (Key Areas)
   - Flutter app: [lib/](lib/)
   - Theme system: [lib/theme/](lib/theme/)
   - Providers: [lib/providers/](lib/providers/)
   - Screens: [lib/screens/](lib/screens/)
   - Widgets: [lib/widgets/](lib/widgets/)
   - Web config: [web/](web/)
   - Chat backend: [chat-backend/](chat-backend/)
   - Admin panel: [admin-panel/](admin-panel/)
   - Assets: [assets/](assets/)
17. Deployment and Environments
   - Flutter web build output in [build/](build/)
   - Firebase configuration via Firebase Console
   - Supabase keys from environment file
18. Roadmap and Next Steps
   - Payments and checkout
   - Reviews and ratings
   - Search improvements and personalization

## Tech Stack Summary

- Frontend: Flutter Web, Dart, Provider, Google Fonts, responsive layout utilities
- Backend Services: Firebase Auth, Firestore, Supabase Storage
- Real-time: Socket.io chat backend
- Admin: Node.js + Express admin panel

## Backend Used (Detail)

1. Firebase Authentication for sign-in (email and Google)
2. Firestore for user profiles and exchange listings
3. Supabase Storage for listing images
4. Node.js admin panel for listing management
5. Node.js chat backend using Socket.io with Firebase ID token verification

## Color Theme

- Primary Yellow: #FFFF00
- Accent Pink: #FF00FF
- Accent Cyan: #00F0FF
- Accent Green: #00FF66
- Black: #000000
- White: #FFFFFF
- Dark Background: #121212

## Folder Structure (Expanded)

- [lib/](lib/)
  - [lib/main.dart](lib/main.dart)
  - [lib/theme/app_theme.dart](lib/theme/app_theme.dart)
  - [lib/providers/](lib/providers/)
  - [lib/screens/](lib/screens/)
  - [lib/widgets/](lib/widgets/)
  - [lib/services/](lib/services/)
  - [lib/config/](lib/config/)
  - [lib/models/](lib/models/)
- [chat-backend/](chat-backend/)
  - [chat-backend/server.js](chat-backend/server.js)
  - [chat-backend/src/](chat-backend/src/)
- [admin-panel/](admin-panel/)
  - [admin-panel/server.js](admin-panel/server.js)
  - [admin-panel/public/](admin-panel/public/)
  - [admin-panel/data/](admin-panel/data/)
- [assets/](assets/)
- [web/](web/)
- [build/](build/)

## Suggested Slide Assets

- UI screenshots from the Home, Auth, and Marketplace screens
- Architecture diagram (simple boxes and arrows)
- Color palette swatches
- Folder structure diagram (tree or columns)

## Build and Demo Commands

- Run web app: `flutter run -d web`
- Build web: `flutter build web --release`
- Run chat backend: `node chat-backend/server.js`
- Run admin panel: `node admin-panel/server.js`