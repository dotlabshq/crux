# Obsidian-Compatible Productivity Structure

The project should stay Obsidian-compatible without requiring a folder named `vault`.

---

## Notes Root

The planning structure should live under a user-selected notes root.
Suggested default:

- `notes/`

Example:

- `notes/00 Inbox/`
- `notes/01 Projects/`
- `notes/02 Areas/`
- `notes/03 Resources/`
- `notes/04 Archives/`
- `notes/Daily Notes/`
- `notes/Weekly Notes/`
- `notes/Templates/`

This keeps the project root cleaner while still allowing the user to open the folder in Obsidian if desired.

---

## Planning Folders Inside The Notes Root

- `00 Inbox/`
- `01 Projects/`
- `02 Areas/`
- `03 Resources/`
- `04 Archives/`
- `Daily Notes/`
- `Weekly Notes/`
- `Templates/`

## Framework Handling

The user may choose:
- `PARA`
- `simple-folder`
- another named framework

Suggested default: `PARA`

Reason:
- easy to explain
- works well with markdown folders
- useful without requiring advanced productivity knowledge

But the framework should stay lightweight.
Do not force PARA-specific language if the user prefers simpler planning.

---

## Placement Guidance

- quick capture and rough triage → `{notes-root}/00 Inbox/`
- active project notes → `{notes-root}/01 Projects/`
- ongoing responsibility areas → `{notes-root}/02 Areas/`
- reference material → `{notes-root}/03 Resources/`
- completed or inactive material → `{notes-root}/04 Archives/`
- date-driven planning notes → `{notes-root}/Daily Notes/` and `{notes-root}/Weekly Notes/`
