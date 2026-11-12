# The agent runner

The examples use Paseo with Claude Code; any runner that offers named agent profiles, worktrees and scheduled prompts will do.

- **Profiles:** Architect (its own provider entry, permissions bypassed, the runner's agent tools on, `AGENT_ROLE=architect`) and Coder (its own provider entry, automatic permission mode, the runner's agent tools off, `AGENT_ROLE=coder`, which the guard reads). The Coder provider's command points at a wrapper that runs the agent as the unprivileged Coder user.
- **The heartbeat:** `heartbeat-prompt.txt`, hourly in the founder's working hours (for example `0 7-23 * * *` in the founder's time zone; Lite profile: two or three times a day). Fill the values in braces.
- **The retro:** `retro-prompt.txt`, weekly, a few hours before the founder's model quota resets, so it spends what the week left over.
- Updating a schedule: change it in place rather than creating a second one with the same job.
