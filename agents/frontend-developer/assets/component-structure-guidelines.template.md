# Component Structure Guidelines

This reference supports component review and implementation work.

## Focus

- keep components scoped to a clear responsibility
- avoid hidden shared-state coupling
- separate shared UI from page-specific UI when practical
- note whether a change affects shared components or local surfaces only

## Review Questions

- Is the component boundary clear?
- Is state local, lifted, or shared intentionally?
- Does this change widen a shared dependency?
- Is the styling approach consistent with the codebase?
