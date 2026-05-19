# Testing Guidelines

- Each test must be **necessary** (not a duplicate of another test), **clear** (title and code match exactly), and **well commented** (explain what is being tested and why)
- Do not create temporary files to immediately read them back — test the logic directly
- Do not add boilerplate around already-tested functions — if `xxx` is tested in one file, don't retest it in another
- Prefer testing edge cases and real-world bugs over happy paths that are already covered
