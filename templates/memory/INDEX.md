# Memory index

What {{PROJECT}} has learned the hard way. Read this first; open a file only when your task touches it. One line per file: what it holds and when to read it. The rules for reading and writing memory are in `docs/OPERATING-MODEL.md`, "Memory".

| File | Holds | Read when |
|---|---|---|
| `gotchas.md` | Things that failed, and what to do instead | Before work in the area an entry names |
| `tool-config.md` | Quirks, flags and limits of the tools, the CI, the board and the vendors | Before using the tool an entry names |

When a file passes about 150 lines, split it by area (for example `gotchas-billing.md`) and add its line here.
