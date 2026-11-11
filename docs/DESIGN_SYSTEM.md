# Design System Principles

This document records the intended visual and interaction language for InsightOS. It is a design baseline, not evidence that every treatment is already implemented.

## Visual atmosphere

Use a restrained ambient gradient as a supporting layer. Colour transitions should be gradual, low-distraction, and stable enough that content remains the visual priority. Background motion must pause or simplify when the page is hidden and must respect `prefers-reduced-motion`.

## Geometric texture

A subtle grid may act as the base texture. Related patterns—such as honeycomb or other modular geometries—can appear as deliberate transitions or context-specific treatments. Pattern changes should preserve visual continuity and avoid flicker, abrupt scaling, or competition with text.

## Material treatments

Glassmorphism, neumorphism, and skeuomorphic details are tools, not default styles:

- **Glass-like surfaces:** reserve for layered contexts; preserve readable contrast and avoid excessive blur.
- **Soft depth:** use sparingly to communicate elevation or interactivity, not as a substitute for clear boundaries.
- **Tactile details:** apply where they clarify a control's affordance or state.

Do not combine effects merely to make every element look different. Components should share a consistent surface, border, shadow, and focus language.

## Motion and time-aware behaviour

- Motion should explain state changes, hierarchy, or continuity.
- Prefer restrained transitions; avoid perpetual motion around primary content.
- Provide a reduced-motion experience that removes non-essential movement.
- Use explicit locale and timezone handling for dates and time-sensitive states.
- Define loading, stale, empty, error, success, and offline states instead of relying on animation alone.

## Accessibility and responsive behaviour

- Maintain readable contrast in every supported theme and background state.
- Ensure keyboard access, visible focus, semantic controls, and accessible names.
- Do not communicate status using colour alone.
- Test layouts at narrow, medium, and wide viewport sizes.
- Ensure decorative effects do not block selection, scrolling, or assistive technology.

## Tokens and component documentation

When implementation begins, define central tokens for colour, spacing, typography, radii, elevation, motion, and layering. Document component anatomy, variants, states, keyboard behaviour, and usage guidance alongside the component source.

## Reference library

Visual references should be stored in a scalable, metadata-driven library. Do not hard-code a maximum count or make adding a reference require a code change for every new item. Preserve source, attribution, review status, and relevant metadata for each reference.
