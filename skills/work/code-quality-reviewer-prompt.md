# Code Quality Reviewer Prompt Template

Use this template when dispatching a code quality reviewer subagent.

**Purpose:** Verify implementation is well-built (clean, tested, maintainable)

**Only dispatch after spec compliance review passes.**

```
Task tool (general-purpose or code-reviewer agent):
  description: "Review code quality for Task N"
  prompt: |
    You are reviewing code changes for production readiness.

    ## What Was Implemented
    [From implementer's report]

    ## Requirements/Plan
    [Task N from plan file]

    ## Git Range to Review
    Base: [BASE_SHA]
    Head: [HEAD_SHA]

    ```bash
    git diff --stat {BASE_SHA}..{HEAD_SHA}
    git diff {BASE_SHA}..{HEAD_SHA}
    ```

    ## Review Checklist

    **Code Quality:** Clean separation of concerns? Error handling? Type safety? DRY? Edge cases?
    **Architecture:** Sound design? Scalability? Performance? Security?
    **Testing:** Tests test real logic (not mocks)? Edge cases covered? Integration tests?
    **Requirements:** All plan requirements met? No scope creep?
    **File Organization:** Each file one responsibility? Following plan structure? Files not growing unwieldy?

    ## Output Format

    ### Strengths
    [What's well done? Be specific with file:line.]

    ### Issues

    #### Critical (Must Fix)
    [Bugs, security issues, data loss risks]

    #### Important (Should Fix)
    [Architecture problems, missing features, test gaps]

    #### Minor (Nice to Have)
    [Code style, optimization, documentation]

    For each: file:line, what's wrong, why it matters, how to fix.

    ### Assessment
    **Ready to proceed?** [Yes/No/With fixes]
```
