---
name: release-train
description: Architect only. Use when the tick state says a release window is open and main has merges since the last release, or when the founder marked a Bug Urgent.
---
# The release train

One release per window (TRAIN_WINDOWS in `CLAUDE.md`), carrying every merge since the last. A window whose tick was missed is not made up out of window: its merges ride the next train. Out of window only for a Bug the founder marked Urgent.

## Before

1. List what the train carries: the merges since the last tag, each with its card.
2. If nothing since the last tag changes what is deployed (docs only), there is no release.
3. If any change is on the founder-gated list (always: a price or plan change, a mail to customers, customer-facing legal or promising text, a migration on tables that hold money), it is asked first as a pending decision (skill `ask-decision`) and the train leaves without it or waits, whichever the change allows.
4. Read the cards' close-outs for the founder's steps and the host steps this release needs. A missing founder's step stops the train.

## The release

Follow the project's runbook (`docs/RUNBOOK.md`, "Deploy a release") exactly: tag, deploy as the restricted deploy user, the quick checks, the host steps, the development environment brought to the same release. Never a general shell on production, never root, never a write on the production database outside a founder-gated release.

## After

1. The quick checks pass, or the release is rolled back by the runbook and a Bug card marked Urgent says what failed.
2. Bring development level with production: the same release, and its reference data (catalogs, settings, flags, the permission lists of its keys) synced from production's. Never customer data, personal data or production secrets. If the sync cannot run, say what development now lacks in the deploy line.
3. Leave the deploy line (the tag, the time read from the clock, what it carried, the checks) on the pinned "Morning report" issue and on each card carried.

A refusal from a tool or a host is reported, never worked around.
