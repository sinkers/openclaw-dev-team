# Skill: HTML Mockup Generator

**Trigger:** Use this skill when asked to generate mockups, wireframes, prototypes, or visual representations of a feature, screen, or product concept.

This skill is part of Scout's toolkit. Mockups are generated early in the product process — before any dev work begins — so the team can align on what is being built visually before writing a line of code.

---

## When to Use

- After a concept or feature has been defined and before handing off to Arch/dev team
- When the user asks for a visual representation of a feature or product
- When a feature has UI components that need to be agreed on before implementation
- As part of the concept → spec → dev pipeline: concept → **mockup** → spec → dev

---

## Output

One or more self-contained `.html` files that:
- Open directly in any browser with no server required
- Include all CSS inline or in a `<style>` block (no external files required)
- Use realistic content — not Lorem Ipsum, not placeholder boxes
- Represent the actual layout, hierarchy, and interactions of the UI
- Link between screens where the flow requires navigation

---

## Process

### Step 1 — Understand the feature

Read the concept doc, feature spec, or user description. Extract:
- What screens/pages are needed
- The user journey through those screens
- Key UI elements: forms, lists, buttons, navigation, modals
- Any known constraints: mobile vs desktop, platform (iOS, Android, web)

If anything is ambiguous, ask one focused clarifying question before generating.

### Step 2 — Plan the screens

List the screens you will generate before writing any HTML. For each screen:
- Name: what is this screen called?
- Purpose: what does the user do here?
- Key elements: what must appear on this screen?
- Navigation: where can the user go from here?

### Step 3 — Generate the HTML files

Generate one `.html` file per screen. Follow these standards:

**Structure:**
```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>[Screen Name] — [Project Name] Mockup</title>
  <style>
    /* All styles here — no external dependencies */
  </style>
</head>
<body>
  <!-- Content -->
  <nav><!-- Navigation links to other screens --></nav>
</body>
</html>
```

**Design standards:**
- Clean, minimal design — the goal is to communicate layout, not to be pixel-perfect
- Use a consistent colour palette across all screens (pick 2–3 colours max)
- Mobile-first where the product is mobile (375px base width)
- Desktop-first for web products (1280px base width)
- Use real content — actual button labels, realistic field names, representative list items
- Navigation between screens: each screen should have links to other screens so the reviewer can click through the flow

**What to avoid:**
- No external CDN links (must work offline)
- No JavaScript frameworks
- No placeholder boxes that say nothing — if a card shows data, show representative data
- No Lorem Ipsum — write real content relevant to the product

### Step 4 — Save the files

Save mockup files to the project mockups directory:
```
<project-root>/mockups/<feature-name>/
  01-<screen-name>.html
  02-<screen-name>.html
  ...
  index.html   ← navigation hub linking all screens
```

Create an `index.html` that lists all screens with links and a one-line description of each. This is the entry point for anyone reviewing the mockups.

### Step 5 — Report back

After generating, report:
1. How many screens were generated and their names
2. The path to `index.html`
3. A brief description of the user flow represented
4. Any assumptions made or open questions for the user

---

## Quality Bar

A good mockup:
- Communicates the UI intent clearly to someone who hasn't read the spec
- Has enough real content that it can be reviewed as a product decision
- Is navigable — reviewer can click through the flow without explanation
- Takes less than 5 minutes to review

A bad mockup:
- Is just boxes and labels with no real content
- Requires the spec to understand what's being shown
- Cannot be clicked through
- Has inconsistent design across screens

---

## Example Invocation

> Scout, generate HTML mockups for the agent settings screen described in this concept.

> Generate mockups for the onboarding flow — 3 screens: welcome, add first agent, confirm setup.

> Create a mockup for the dashboard showing agent status cards.

---

## References

See `references/mockup-example.html` for a worked example of the expected output quality.
