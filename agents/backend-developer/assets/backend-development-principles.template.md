# Backend Development Principles

This reference supports `backend-developer`.

## Purpose

Provide implementation and review rules for backend work without tying the permanent
agent to any single language or framework.

## Principles

- Preserve existing service boundaries unless there is a clear reason to change them
- Prefer explicit contracts over hidden coupling
- Keep business logic out of transport glue when possible
- Explain behaviour-changing edits before making them
- Treat persistence-sensitive paths as risk surfaces

## Review Focus

- contract clarity
- service boundaries
- error handling
- test coverage
- schema-sensitive impact

## Style Rules

- prefer concrete file references
- keep changes local unless refactor scope is explicit
- avoid silent behavioural drift
