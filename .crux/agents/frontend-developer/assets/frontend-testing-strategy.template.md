# Frontend Testing Strategy

This reference supports frontend validation and test planning.

## Purpose

Keep frontend test guidance practical and tied to user-visible behaviour.

## Default Expectations

- add tests for meaningful interaction changes when practical
- if not adding tests, explain why
- prefer behaviour-oriented tests over fragile implementation tests
- call out remaining UI risk where coverage is thin

## Useful Test Layers

- component tests for isolated UI behaviour
- integration tests for state and interaction flow
- route or page tests for key user journeys where relevant
