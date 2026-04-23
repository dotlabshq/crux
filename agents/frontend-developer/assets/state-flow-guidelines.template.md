# State Flow Guidelines

This reference supports review of frontend state and interaction flow.

## Focus

- make state ownership explicit
- note shared state and propagation paths
- highlight risky coupling between routes, stores, or providers
- call out broad interaction fallout before editing shared state

## Review Questions

- Where does this state live?
- Who reads it?
- Who mutates it?
- What other surfaces are affected by this change?
