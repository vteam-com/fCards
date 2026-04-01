# Implementation Plan

## Goal

Repair the "Create New Table" UX so the flow is responsive and predictable:

1. Enter table name
2. Detect whether the table already exists
3. Either continue with create flow or offer a clear join shortcut
4. Reflect create/join actions immediately in UI

## Steps

1. Audit `StartScreen` create-room state transitions and identify stale state paths.
2. Add deterministic room-lookup state so existing-player checks only apply to the currently typed table.
3. Make create/join/remove actions update local UI immediately (without waiting for backend stream).
4. Harden room lookup with safe async guards to avoid stuck loading or stale callbacks.
5. Run `./tool/check.sh` and fix any issues.
