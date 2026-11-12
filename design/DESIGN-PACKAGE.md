# Design package: {{PROJECT}}

Produced by the Designer in the design session (`DESIGN-PHASE.md`), read by the architect at kickoff (`../KICKOFF.md`). Every section is filled; "not now, because ..." is an answer, a blank is not.

**Founder:** {{FOUNDER}}. **Date of "go":** {{DATE}}. **Design session:** {{LINK OR FILE}}.

## 1. The goal
What success is, measured how, by when. The pre-mortem: why this could fail, and what we do about each reason.

## 2. The users
Who, what they do today instead, why they switch, what they pay.

## 3. The market
Competitors and alternatives, each with what they do well and badly and what users complain about (sources and dates). The positioning: where this project leads rather than follows.

## 4. The first release
The features (the smallest version that reaches the goal), each with its acceptance in one sentence. What is left out and why. What comes after, in order.

## 5. The look
Mockups (files in `mockups/`): landing, first screen after sign-up, the main working screens, settings, billing. The visual style and the tone of the copy; the languages.

## 6. The journey and onboarding
The user journey from first contact to a paying, returning user (`journey.md` or an image). Onboarding step by step, with the first value moment marked; where users drop off and what catches them.

## 7. The business model
Prices, cost per user, margin, the free tier and its abuse limits, payments and refunds.

## 8. The architecture
Stack, hosting, data, integrations and vendors, build-versus-buy, environments. Which of these are **locked** (they become CLAUDE.md's locked decisions).

## 9. Security, abuse, privacy and legal
Accounts and authentication, secrets, permissions, fraud and rate limits, personal data and retention, terms and privacy, regulated data, licenses.

## 10. Operations and metrics
Deploys and rollback, backups, monitoring, support, the release rhythm. The metrics from day one and where they are read.

## 11. Risks
Each risk, its mitigation, and the signal that it is happening.

## 12. Decisions taken
D1, D2, ... each with who, the reasoning (options weighed, the deciding facts, why) and the signal to revisit. They keep their numbers at kickoff.

## 13. Open questions
Each with who decides it and whether it blocks the first release. They become pending decisions at kickoff.

## 14. Constraints for the build
The profile (Full or Lite). Budget (vendor and model spend ceilings), the founder's model quota and its reset, the deadline if any, the founder's availability for decisions.
