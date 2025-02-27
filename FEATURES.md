# AllerGuard Features

*Last Updated: February 27, 2025*

This document outlines the features of AllerGuard, including their scope, boundaries, and dependencies.

## Core Features

### 1. Restaurant Menu Scanning & Filtering

**Purpose**: Enable users to scan restaurant menus and receive personalized, allergen-safe dining options with substitution suggestions.

**Components**:
- Menu-specific OCR optimization
- Menu item filtering based on user's allergen profile
- Substitution recommendation engine
- Safe/unsafe dish highlighting
- Restaurant database integration

**Dependencies**:
- Camera Service
- OCR Service
- Allergen Detection Service
- User Profiles
- Restaurant database

**Boundaries**:
- Provides personalized menu filtering based on allergen profiles
- Offers substitution suggestions for menu items
- Displays only items that match the user's safety criteria
- Highlights potential cross-contamination risks
- Maintains appropriate cautionary notices about restaurant compliance

**Owner**: Restaurant Team

---

### 2. Camera Scanning

**Purpose**: Allow users to capture images of ingredient labels for processing.

**Components**:
- Camera preview interface
- Capture button
- Focus and stabilization assistance
- Image processing for optimal OCR

**Dependencies**:
- PermissionService (for camera access)
- CameraService

**Boundaries**:
- Responsible only for capturing clear images
- Passes captured images to OCR service
- Does not perform text recognition or allergen detection

**Owner**: Camera Team

---

### 3. OCR (Optical Character Recognition)

**Purpose**: Extract text from ingredient label images.

**Components**:
- Text recognition service
- Text preprocessing
- Text cleaning and normalization
- Language detection

**Dependencies**:
- Vision framework
- Core Image for image preprocessing

**Boundaries**:
- Focuses solely on extracting text, not interpreting it
- Handles multiple text orientations and formats
- Optimizes for ingredient label typography
- Provides confidence scores for detection quality

**Owner**: OCR Team

---

### 4. Allergen Detection

**Purpose**: Identify potential allergens in the extracted ingredient text.

**Components**:
- Allergen matching algorithm
- Ingredient parsing engine
- Synonym and variant detection
- Confidence level indicators

**Dependencies**:
- OCR Service
- User's allergen profile
- Allergen database

**Boundaries**:
- Focuses only on matching ingredients to known allergens
- Does not handle image capture or text extraction
- Responsible for identifying hidden allergens (e.g., "casein" for milk allergy)

**Owner**: Allergen Detection Team

---

### 5. User Profiles

**Purpose**: Allow users to manage their allergen sensitivities and preferences.

**Components**:
- Profile creation and editing
- Allergen selection interface
- Severity level settings
- Multiple profile support (e.g., family members)

**Dependencies**:
- StorageService
- AllergenService (for allergen database)

**Boundaries**:
- Manages user data and preferences
- Does not perform allergen detection
- Provides allergen profile data to detection service

**Owner**: Profile Team

---

### 6. Scan History

**Purpose**: Store and display history of previous scans and results.

**Components**:
- History list view
- Detailed scan result view
- Search and filtering
- Result sharing
- Restaurant menu scan history

**Dependencies**:
- StorageService
- OCRService (for displaying recognized text)
- AllergenService (for displaying detected allergens)

**Boundaries**:
- Only manages storage and display of past results
- Does not perform new scans or detection
- Provides historical data for analysis and reference
- Stores restaurant menu preferences for frequent locations

**Owner**: History Team

---

## Enhanced Features (Phase 2)

### 7. Allergen Education

**Purpose**: Provide educational content about allergens and reactions.

**Components**:
- Allergen information database
- Educational content views
- Reaction symptoms information
- Avoidance recommendations

**Dependencies**:
- AllergenService
- User Profiles

**Boundaries**:
- Focuses only on providing information
- Does not diagnose or provide medical advice
- Complements the allergen detection feature

**Owner**: Education Team

---

### 8. Emergency Contacts

**Purpose**: Allow users to quickly contact emergency help in case of allergic reactions.

**Components**:
- Contact management
- Quick dial interface
- Location sharing
- Emergency instructions

**Dependencies**:
- User's contact list
- Location services

**Boundaries**:
- Limited to communication features
- Does not provide medical treatment advice
- Focuses on speed and reliability in emergency situations

**Owner**: Safety Team

---

### 9. Alternative Suggestions

**Purpose**: Suggest alternative products or menu items for items that contain the user's allergens.

**Components**:
- Product alternatives database
- Menu substitution engine
- Suggestion algorithm
- Alternative viewing interface
- Custom substitution preferences

**Dependencies**:
- AllergenService
- Product database
- Restaurant menu database

**Boundaries**:
- Provides only suggestions, not guarantees
- Requires connection to product database
- Limited to known alternative products
- Suggests menu modifications based on restaurant capabilities
- Allows users to save preferred substitutions

**Owner**: Alternatives Team

---

## Future Features (Phase 3)

### 10. Community Features

**Purpose**: Allow users to share and validate allergen information with the community.

**Components**:
- Community database of scanned products and menus
- Restaurant reviews and allergen safety ratings
- Verification system
- User contribution tracking
- Restaurant recommendation engine

**Dependencies**:
- User Profiles
- Scan History
- Backend services (to be developed)

**Boundaries**:
- Maintains privacy of user health data
- Focuses on product information, not personal details
- Includes moderation system for accuracy
- Provides community-verified restaurant allergen information

**Owner**: Community Team

---

### 11. Product Label Scanning Enhancement

**Purpose**: Advanced detection and analysis features for packaged food labels.

**Components**:
- Barcode/QR code scanning
- Product database integration
- Nutritional information extraction
- Advanced allergen warning detection

**Dependencies**:
- Camera Scanning
- OCR Service
- Allergen Detection
- Product database (to be integrated)

**Boundaries**:
- Complements the restaurant menu scanning feature
- Provides detailed analysis of packaged foods
- Integrates with product databases for enhanced information

**Owner**: Product Team

---

## Feature Dependency Graph

```
                           ┌────────────────┐
                           │                │
                           │  User Profiles │
                           │                │
                           └────────┬───────┘
                                    │
                                    ▼
┌───────────────┐  ┌─────► ┌────────────────┐ ◄─────┐  ┌───────────────┐
│               │  │       │                │        │  │               │
│Camera Scanning├──┘       │Allergen Service├────────┼─►│  Scan History │
│               │          │                │        │  │               │
└───────┬───────┘          └────────┬───────┘        │  └───────────────┘
        │                           │                │
        ▼                           ▼                │
┌───────────────┐          ┌────────────────┐       │
│               │          │                │       │
│  OCR Service  ├─────────►│Allergen Detection├──────┘
│               │          │                │
└───────────────┘          └────────────────┘
```

## Feature Implementation Status

| Feature | Status | Priority | Target Release |
|---------|--------|----------|----------------|
| Camera Scanning | Not Started | High | v1.0 |
| OCR | Not Started | High | v1.0 |
| Allergen Detection | Not Started | High | v1.0 |
| User Profiles | Not Started | High | v1.0 |
| Scan History | Not Started | Medium | v1.0 |
| Allergen Education | Planned | Medium | v1.5 |
| Emergency Contacts | Planned | Medium | v1.5 |
| Alternative Suggestions | Planned | Low | v2.0 |
| Community Features | Future | Low | v2.5 |
| Restaurant Menu Scanning | Future | Low | v3.0 |
| Product Label Scanning Enhancement | Future | Low | v3.5 | 