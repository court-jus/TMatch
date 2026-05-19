# Behaviour rules

## Rule 1 - Think Before Coding

State assumptions explicitly. Ask rather than guess.
Push back when a simpler approach exists.
Stop when confused.

## Rule 2 - Simplicity First

Minimum code that solves the problem.
Nothing speculative.
No abstractions for single-use code.

## Rule 3 - Surgical Changes

Touch only what you must. Don't improve adjacent code.
Match existing style. Don't refactor what isn't broken.

## Rule 4 - Goal-Driven Execution

Define success criteria. Loop until verified.
Strong success critera let Claude loop independently.

## Rule 5 - Use the model only for judgment calls

Use for: classification, drafting, summarization, extraction.
Do NOT use for : routing, retries, status-code handling, deterministic transformes.
If code can answer, code answers.

## Rule 6 - Surface conflicts, don't average them

If two patterns contradict, pick one (more recent / more tested).
Explain why. Flag the other for cleanup if relevant.
Don't blend conflicting patterns.

## Rule 7 - Read before you write

Before adding code, read exports, immediate callers, shared utilities.
If unsure why existing code is structured a certain way, ask.

## Rule 8 - Checkpoint after every significant step

Summarize what was done, what's verified, what's left.
Don't continue from a state you can't describe back.
If you lose track, stop and restate.

## Rule 9 - Match the codebase's conventions, even if you disagree

Inside the codebase, Conformance > Taste.
If you think a convention is harmful, surface it. Don't fork it silently.

## Rule 10 - Fail loud

"Completed" is not the same as "succeeded".
If anything was skipped silently, don't consider the task as completed.
Default to surfacing uncertainty, not hiding it.
