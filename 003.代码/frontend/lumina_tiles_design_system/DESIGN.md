---
name: Lumina Tiles Design System
colors:
  surface: '#fcf9f8'
  surface-dim: '#dcd9d9'
  surface-bright: '#fcf9f8'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f6f3f2'
  surface-container: '#f0eded'
  surface-container-high: '#eae7e7'
  surface-container-highest: '#e4e2e1'
  on-surface: '#1b1c1c'
  on-surface-variant: '#404753'
  inverse-surface: '#303030'
  inverse-on-surface: '#f3f0ef'
  outline: '#707785'
  outline-variant: '#c0c7d6'
  surface-tint: '#005fae'
  primary: '#005daa'
  on-primary: '#ffffff'
  primary-container: '#0075d5'
  on-primary-container: '#fefcff'
  inverse-primary: '#a5c8ff'
  secondary: '#595f67'
  on-secondary: '#ffffff'
  secondary-container: '#dee3ed'
  on-secondary-container: '#5f656d'
  tertiary: '#b71423'
  on-tertiary: '#ffffff'
  tertiary-container: '#db3239'
  on-tertiary-container: '#fffbff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d4e3ff'
  primary-fixed-dim: '#a5c8ff'
  on-primary-fixed: '#001c3a'
  on-primary-fixed-variant: '#004785'
  secondary-fixed: '#dee3ed'
  secondary-fixed-dim: '#c1c7d0'
  on-secondary-fixed: '#161c23'
  on-secondary-fixed-variant: '#41474f'
  tertiary-fixed: '#ffdad7'
  tertiary-fixed-dim: '#ffb3ae'
  on-tertiary-fixed: '#410005'
  on-tertiary-fixed-variant: '#930016'
  background: '#fcf9f8'
  on-background: '#1b1c1c'
  surface-variant: '#e4e2e1'
  hover-blue: '#40A9FF'
  deep-blue: '#096DD9'
  success-green: '#52C41A'
  warning-orange: '#FAAD14'
  text-gray: '#8C8C8C'
  divider-gray: '#F0F0F0'
  surface-white: '#FFFFFF'
typography:
  headline-lg:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  headline-md:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '600'
    lineHeight: 28px
  headline-sm:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '600'
    lineHeight: 26px
  body-lg:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 22px
  body-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '400'
    lineHeight: 18px
  label-md:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
    letterSpacing: 0.02em
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '500'
    lineHeight: 16px
    letterSpacing: 0.01em
  price-display:
    fontFamily: Inter
    fontSize: 20px
    fontWeight: '700'
    lineHeight: 24px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 8px
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
  gutter: 12px
  margin-mobile: 16px
---

## Brand & Style

The design system is engineered for a high-end tile retail experience, emphasizing **professionalism, precision, and architectural space**. The target audience ranges from homeowners seeking inspiration to contractors requiring technical specifications. 

The visual language follows a **Modern Minimalist** approach. It leverages generous whitespace to mimic the "gallery" feel of a physical showroom, ensuring that the high-definition textures of the tile products remain the focal point. By utilizing a "Sky Blue" primary palette against an "Ultra Light Blue" background, the UI evokes a sense of cleanliness and structural integrity. 

Key stylistic principles include:
- **Spatial Clarity:** Deep margins and intentional negative space to prevent visual clutter.
- **Lightweight Elevation:** Using subtle borders and tonal shifts rather than heavy shadows to maintain a flat, modern aesthetic.
- **Technical Precision:** Crisp typography and systematic alignment that mirror the geometric nature of the product.

## Colors

The color palette is rooted in a professional "Sky Blue" spectrum, designed to feel airy and dependable. 

- **Primary (#1890FF):** Used for primary actions, selection states, and active navigation. It represents the brand's interactive core.
- **Secondary/Background (#F0F5FF):** This ultra-light blue serves as the global canvas, providing more depth and sophistication than pure white.
- **Accent/Price (#FF4D4F):** Reserved exclusively for pricing, promotions, and critical alerts. Its high contrast against the blue palette ensures immediate recognition of value.
- **Neutral Hierarchy:** 
    - `#262626` (Text Black) is used for titles to ensure maximum legibility.
    - `#8C8C8C` (Text Gray) handles secondary information and captions.
    - `#F0F0F0` (Divider) creates subtle boundaries without breaking the flow of the page.

## Typography

This design system utilizes a **system-default sans-serif** stack (rendered here as Inter for systematic consistency) to ensure performance and familiarity within the WeChat ecosystem. 

The typographic hierarchy is structured to handle complex product data:
- **Headlines:** Use Semi-bold weights to anchor page sections and product names.
- **Body Text:** Uses a standard 14px size for product specifications and descriptions to maintain a clean, readable density.
- **Price Display:** A specialized style using the "Price Red" color and bold weight to emphasize the commercial nature of the platform.
- **Captions:** Smaller 12px text in "Text Gray" is used for metadata, secondary specs, and legal footers.

## Layout & Spacing

The design system employs an **8px linear stepping scale** for all dimensions, ensuring a rhythmic and predictable layout.

- **Grid Model:** A fluid grid with a standard 16px (2 units) side margin for mobile. 
- **Product Lists:** Uses a two-column waterfall or "grid" layout with a 12px gutter to balance density with image visibility.
- **Rhythm:** 
    - **16px (md):** Standard padding for cards and containers.
    - **8px (sm):** Internal spacing between related elements (e.g., product name and price).
    - **24px-32px (lg-xl):** Vertical spacing between major page sections or card groups.
- **Mobile Adaptivity:** Bottom navigation and primary CTA bars are fixed to the viewport bottom with a safe-area-inset-bottom to ensure accessibility on all device types.

## Elevation & Depth

To maintain a "Professional & High-Quality" feel, the system avoids heavy, dark shadows in favor of **Tonal Layering** and **Low-Contrast Outlines**.

1.  **Level 0 (Base):** The global background uses the "Ultra Light Blue" (`#F0F5FF`).
2.  **Level 1 (Surface):** Cards and interactive containers use "Surface White" (`#FFFFFF`). They are defined by a 1px border of "Divider Gray" (`#F0F0F0`) rather than a shadow.
3.  **Level 2 (Interaction):** Upon hover or active state, cards may gain a very soft, diffused ambient shadow (Opacity 5%, 8px blur) to suggest "lifting" off the surface.
4.  **Level 3 (Overlays):** Modals and bottom sheets use a standard backdrop dimming (40% black) to focus the user’s attention on the interaction.

## Shapes

The shape language is defined by a consistent **8px (0.5rem) corner radius**, striking a balance between modern friendliness and professional structure.

- **Cards & Inputs:** Use the base 8px radius to create a unified container language.
- **Buttons:** Large action buttons also follow the 8px rule, avoiding fully rounded "pills" to maintain a more architectural, stable look.
- **Tags & Chips:** May use a smaller 4px radius or the standard 8px depending on scale, but never sharp 0px corners.
- **Product Images:** Images within cards should inherit the container's 8px rounding to ensure the texture of the tiles feels integrated into the UI.

## Components

### Buttons
- **Primary:** Solid Brand Blue (`#1890FF`) with White text. Used for "Buy Now" or "Submit."
- **Secondary:** Ghost style with Brand Blue border and text. Used for "Add to Cart" or "View Details."
- **Sizing:** Minimum height of 44px for touch targets.

### Cards (Lightweight)
- White background, 8px rounded corners, 1px `#F0F0F0` border.
- Used for product items in the waterfall and order history items.
- Content should be padded with 12px-16px.

### Input Fields
- Clear, labeled fields with an 8px radius. 
- Focus state is indicated by a 1px Brand Blue border and a subtle `#E6F7FF` glow.

### Status Chips
- Small, low-saturation backgrounds with high-saturation text.
- Success: Light Green bg / Deep Green text.
- Warning: Light Orange bg / Deep Orange text.

### Product Detail Table
- A clean, borderless table style with horizontal `#F0F0F0` dividers only. 
- Left column (Labels) in Text Gray; Right column (Values) in Text Black.

### Navigation
- **Bottom Bar:** 4-5 icons (Home, Category, Cart, Profile). Unselected icons in Text Gray; selected in Brand Blue.
- **Tabs:** Simple text tabs with a 2px Brand Blue underline for the active state.