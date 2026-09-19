---
globs: ["**/*.go"]
description: Go refactoring rules
---

[RULES: GO_REFACTORING]

IDIOMS:
- Max 40 lines/function. Receiver: 1–2 letters, consistent across methods.
- Accept interfaces, return structs. Context is strictly first parameter.
- Errors are values: handle explicitly (FORBID panic).
- FORBID globals (inject dependencies). FORBID init() unless forced by dependency.

HEXAGONAL_ARCHITECTURE:
- Ports (interfaces) in domain; adapters implement ports (domain imports adapters ≡ ∅).
- Zero infrastructure types in domain signatures.

POST_REFACTOR_GATES:
- Zero issues: `go vet ./...`, `golangci-lint run`, `go test -race ./...`.
- Goroutine leaks: Assert zero leaks via goleak in tests.

LADDER_EXTENSIONS:
- Rung 2: strings, strconv, slices, maps before external imports.
- Rung 3: net/http before gin/chi/echo; database/sql before ORMs.
- Rung 4: Reuse stdlib interfaces (io.Reader, fmt.Stringer); custom duplicates FORBIDDEN.
- Omit constructor if zero-value usable; omit getter/setter if field can be public.

PERFORMANCE_GUARDRAILS (Hot-path overrides):
- Stdlib overrides on hot paths:
  * fmt.Sprintf in loop ⇒ strings.Builder
  * json.Marshal per request ⇒ pre-compiled codec (easyjson, sonic)
  * regexp.MatchString per request ⇒ compile once at init
  * http.Get convenience ⇒ reuse pooled http.Client
- One-liner overrides on hot paths:
  * append() in hot loop without sizing ⇒ make([]T, 0, n)
  * Map access with dense integer keys ⇒ slice index lookup
  * interface{} / any on hot path ⇒ concrete type (avoids heap boxing)
- sync.Pool for high-churn allocations (byte buffers, request objects).
- reflect on hot paths FORBIDDEN (allocates per call).
- Concurrency: Mutex to protect-and-release; Channel for hand-off.