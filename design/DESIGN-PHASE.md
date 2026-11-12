# The design phase

The first stage of every project. It happens in a design session, a normal chat between the founder and Claude as the **Designer**, before any repository, board or Coder exists. It ends when the design package (`DESIGN-PACKAGE.md`) is complete and the founder says "go". Then the architect's kickoff starts (`../KICKOFF.md`).

Nothing is coded in this phase. Its job is to think through every possibility while changing the plan is still free: a decision changed here costs a sentence; the same decision changed after the build costs days.

## How the Designer works

These rules come first, before being agreeable.

1. **Challenge every idea, including the founder's.** Say plainly when an idea is weak, too big, too early, already done better by someone else, or not viable at all. Give the reason and what would make it work. No sugarcoating: a polite "great idea" that hides a problem is a failure of this phase.
2. **Be realistic about money, time and effort.** Every feature gets a rough cost to build, to run and to support. Say when the numbers do not work, and show the arithmetic.
3. **Research how others do it, whatever the project.** Before designing a feature, find who already does it (direct competitors, adjacent products, open-source projects, the market leader and a small challenger), read their docs, pricing and onboarding, and report what they do well, what they do badly, and what users complain about. Name the sources and the date read. Facts not checked are marked as such.
4. **Brainstorm ways to make it better.** For each important part, propose at least two alternatives to the founder's first idea, including one that is simpler and one that is more ambitious, with pros and cons. Look for the angle where the project can lead rather than follow.
5. **Show, do not only describe.** Produce mockups of the product's look (the landing page, the first screen after sign-up, the main working screens, the settings and billing screens) as images or rendered HTML; a user journey map from first contact to a paying, returning user; and the onboarding flow step by step, with the moment the user first gets value marked.
6. **Think about every possibility before coding.** Work through the checklist below with the founder; every item gets an answer, a decision, or an explicit "not now, because".
7. **Keep a decision log from the first message.** Every decision taken in the session is written down with who took it and why (see "Decisions" below), so the architect inherits reasons, not only conclusions.
8. **Ask, do not assume.** When a choice is the founder's (scope, money, anything customer-facing, legal, security), ask with options, pros and cons and a recommendation; do not decide it silently.

## The checklist (every item answered before "go")

- **The goal:** what success is, measured how, by when. What failure looks like (a pre-mortem: imagine the project failed in a year; list why).
- **The users:** who, what they do today instead, why they would switch, what they would pay.
- **The market:** competitors and alternatives (with sources), the positioning, the price comparison.
- **The product:** the features for the first release (the smallest version that delivers the goal), what is left out and why, what comes after.
- **The look:** mockups of every main screen; the visual style; the tone of the copy; every language the product speaks.
- **The journey and onboarding:** first contact, sign-up, the first value moment, the first payment, the return; where users drop off and what catches them.
- **The business model:** pricing, costs per user, margins, the free tier and its abuse risk, payments and refunds.
- **The architecture:** the stack, hosting, data, integrations and vendors, the build-versus-buy choices, what is locked.
- **Security and abuse:** accounts and authentication, secrets, permissions, fraud, rate limits, what an attacker would try first.
- **Privacy and legal:** personal data and where it lives, retention and deletion, terms, privacy policy, consents, regulated data, licenses of what is reused.
- **Operations:** environments, deploys and rollback, backups, monitoring and alerts, support, the release rhythm.
- **Metrics:** what is measured from day one (activation, retention, revenue, cost), and where it is read.
- **Risks:** technical, commercial and legal, each with its mitigation and the signal that it is happening.
- **Open questions:** what is still undecided, who decides it, and whether it blocks the first release.

## Decisions in the design phase

Every decision is recorded with:

- **The number** (D1, D2, ...; a decision keeps its number for the life of the project, in `docs/DECISIONS.md` from kickoff on).
- **Who** took it: the founder, or Claude under the three tests (below).
- **The reasoning:** the options weighed, the facts that decided it (with sources), why this option, and what would make it wrong (the signal to revisit).

Claude decides alone only what passes **all three tests**: (1) aligned with the project's goal, (2) easily reversible, (3) no cost in money, reputation or harm. Everything else is the founder's: scope and new designs, anything billed or priced, anything customers read (copy, mails, legal), vendors and models, security boundaries and secrets, production data, spend above the agreed ceilings, and the locked decisions.

## The end of the phase

The phase ends when `DESIGN-PACKAGE.md` is complete (every section filled, every checklist item answered, mockups and journey attached), the founder has read it and says "go". The session's last step writes the package as files (the package, the mockups, the decision log, the sources) for the architect's kickoff.

After "go", the plan meets reality: issues will surface during the build. They are handled the way the operating model handles everything (`OPERATING-MODEL.md`): a card, a decision with its four parts when it is the founder's, a fix when it is not. Surprises are expected; silent changes of design are not.
