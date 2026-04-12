# Handoff

This content is loaded when Phase 6 begins -- after the requirements document is written and reviewed.

---

#### Present Next-Step Options

Use the platform's blocking question tool when available (`AskUserQuestion` in Claude Code, `request_user_input` in Codex, `ask_user` in Gemini). Otherwise present numbered options in chat and end the turn.

If `Resolve Before Planning` contains any items:
- Ask the blocking questions now, one at a time, by default
- If the user explicitly wants to proceed anyway, first convert each remaining item into an explicit decision, assumption, or `Deferred to Planning` question
- If the user chooses to pause instead, present the handoff as paused or blocked rather than complete
- Do not offer `Proceed to planning` or `Proceed directly to work` while `Resolve Before Planning` remains non-empty

Present only the options that apply:
- **Proceed to planning (Recommended)** -- invoke sp-compound:plan with the requirements doc path
- **Proceed directly to work** -- only offer when scope is lightweight, success criteria are clear, scope boundaries are clear, and no meaningful technical or research questions remain. Invoke sp-compound:work.
- **Ask more questions** -- return to Phase 2 Q&A
- **Done for now** -- return later

If the direct-to-work gate is not satisfied, omit that option entirely.

#### Closing Summary

Use the closing summary only when this run of the workflow is ending or handing off, not when returning to the options above.

When complete and ready for planning:

```text
Brainstorm complete!

Requirements doc: <path>  (if one was created)

Key decisions:
- [Decision 1]
- [Decision 2]

Recommended next step: sp-compound:plan
```

If the user pauses with `Resolve Before Planning` still populated:

```text
Brainstorm paused.

Requirements doc: <path>  (if one was created)

Planning is blocked by:
- [Blocking question 1]
- [Blocking question 2]

Resume with sp-compound:brainstorm to resolve these before planning.
```
