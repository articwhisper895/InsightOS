# Project Overview

## Summary

InsightOS is a digital workspace project focused on bringing useful information and workflows together in a calm, coherent interface. Its product direction values clarity, adaptability, and dependable interaction over visual novelty for its own sake.

## Product principles

### 1. Make information understandable

Use explicit labels, meaningful grouping, consistent navigation, and progressive disclosure. Important actions and system states must never depend on colour or animation alone.

### 2. Adapt without surprising the user

Context-aware behaviour should be predictable, explainable, and reversible where practical. Time-sensitive content must use a clearly defined timezone and handle date boundaries correctly.

### 3. Treat performance as part of the experience

Animation, decorative layers, and media must not make core tasks slower. Prefer transform and opacity for motion, avoid unnecessary layout recalculation, and provide reduced-motion alternatives.

### 4. Build an extensible system

Components, tokens, and visual references should be organised around metadata and reusable conventions. Adding a reference or extending a design pattern should not require hard-coded collection limits or one-off application changes.

## Scope discipline

The repository must distinguish between shipped capabilities, work in progress, and ideas. README feature claims, screenshots, performance statements, and compatibility claims should be added only after they have been verified against the current implementation.

## Audience and workflows

The confirmed target audience, primary workflows, and measurable product outcomes should be documented here as those decisions are finalised. Avoid inventing personas or promising unsupported capabilities.

## Product decisions

Record significant product decisions in concise documents under `docs/decisions/`. Each decision should capture its context, selected approach, alternatives considered, and consequences.
