---
name: github-issue-investigator
description: Investigates potential bugs by searching GitHub issues, exploring relevant code, and creating comprehensive investigation reports with reproduction steps. Use when the user reports a bug, wants to check if an issue has been reported, or needs help understanding a problem in their codebase.
---

# GitHub Issue Investigator

Autonomous workflow for investigating bugs by searching GitHub issues, analyzing code, and creating detailed investigation reports.

## When to Use This Skill

Invoke this skill when the user:
- Reports a bug or unexpected behavior
- Wants to check if an issue has been reported on GitHub
- Asks "has anyone else experienced this?"
- Wants to understand if a problem is known or fixed
- Needs help reproducing or understanding an issue

## Workflow Execution

Execute all steps autonomously. Ask clarifying questions ONLY for:
1. Which GitHub repository to search (if not obvious from context)
2. Specific symptoms if the user's description is too vague

### Step 1: Understand the Problem

**Gather information:**
- What is the expected behavior?
- What is the actual behavior?
- When does it occur? (always, intermittently, specific conditions)
- What actions trigger it? (specific UI interactions, API calls, etc.)
- Any error messages or console output?

**If information is unclear:**
- Use `AskUserQuestion` to clarify specific symptoms
- Focus on observable behavior, not hypotheses
- Maximum 4 questions, preferably 2-3

### Step 2: Explore Relevant Code Areas

**Use Task tool with Explore agent:**
```
Launch Explore agent to:
1. Find code related to the reported symptoms
2. Understand the architecture and data flow
3. Identify state management, navigation, or loading logic
4. Look for performance optimizations that might cause issues
5. Find similar patterns or known problem areas
```

**Focus areas:**
- State management (Redux, Zustand, Context, etc.)
- Navigation/routing logic
- Data loading and caching
- UI components that display the affected data
- API calls and async operations

**Document findings:**
- File paths with line numbers
- Code snippets showing potential issues
- Data flow diagrams or explanations
- Potential race conditions or timing issues

### Step 3: Search GitHub Issues

**Required searches using `gh` CLI:**

1. **Search by keywords from symptoms:**
   ```bash
   gh issue list --repo OWNER/REPO --limit 100 --search "keyword1 keyword2" --state all
   ```

2. **Search by component/feature:**
   ```bash
   gh issue list --repo OWNER/REPO --limit 100 --search "component-name" --state all
   ```

3. **Search for related terms:**
   - If about navigation: search "navigation", "routing", "URL"
   - If about data display: search "wrong data", "stale", "cache"
   - If about performance: search "slow", "lag", "performance"

**For promising issues:**
```bash
gh issue view ISSUE_NUMBER --repo OWNER/REPO --json title,body,state,closedAt,comments
```

**Categorize issues:**
- **Closed & relevant:** Note fix date, related PRs, check if fix is in current code
- **Open & similar:** Link to issue, assess if it's the same problem
- **Closed but user still experiencing:** Potential regression

### Step 4: Analyze Code for Root Cause

**Based on code exploration and issue research:**

1. **Identify the likely root cause:**
   - What specific code location is problematic?
   - Why does it cause the observed behavior?
   - What's the mechanism (race condition, stale state, etc.)?

2. **Explain the data flow:**
   - Normal/working case
   - Bug case (what goes wrong and when)
   - Use numbered steps with clear before/after states

3. **Note related issues:**
   - Link to similar GitHub issues
   - Explain how this differs from previous fixes
   - Check if it's a regression

### Step 5: Create Reproduction Steps

**Format:**
```markdown
### Setup
[Prerequisites, data requirements, environment setup]

### Test Case 1: [Basic scenario]
1. [Action]
2. [Action]
3. **Observe:** [What to look for]
4. **Expected:** [What should happen]
5. **Bug:** [What actually happens]

### Test Case 2: [Edge case]
[Similar format]

[Include 3-5 test cases covering different scenarios]
```

**Include:**
- Basic reproduction (simplest case)
- Edge cases (rapid clicks, slow network, etc.)
- Diagnostic checks (browser console, duplicate IDs, etc.)
- Code inspection methods (adding logging, breakpoints)

### Step 6: Create Investigation Report

**Save to plan file if in plan mode, otherwise create new file:**

Create `/Users/[user]/.claude/investigations/[repo-name]-[issue-description].md`

**Report structure:**

```markdown
# Investigation: [Issue Title]

## User-Reported Symptoms
- **When:** [Timing/context]
- **What:** [Behavior observed]
- **Frequency:** [Always/intermittent/specific conditions]
- **[Other key details]**

## Related GitHub Issues

### Closed Issues (Previously Fixed)
[For each relevant issue:]
#### Issue #[NUM] - "[Title]"
- **Status:** CLOSED ([date])
- **Description:** [Brief description]
- **Resolution:** [How it was fixed]
- **Relevance:** [Why it matters to this investigation]

### Open Issues (Possibly Related)
[Similar format for open issues]

## Key Code Areas

### 1. [Component/Area Name]
**File:** `path/to/file.ext` (lines X-Y)

```[language]
[Relevant code snippet]
```

**Why this matters:** [Explanation]
**Potential problem:** [What could go wrong here]

[Repeat for 3-6 key code areas]

## Data Flow Analysis

### Normal Flow (Working Case)
```
1. [Step]
2. [Step]
[...]
```

### Bug Flow (What's Happening)
```
1. [Step]
2. [Step]
3. ⚠️ [Where things go wrong]
4. ⚠️ [Consequence]
[...]
```

## Reproduction Steps

[Include 3-5 test cases as outlined in Step 5]

## Questions to Answer

### 1. [Question about cause/regression/timing]
[Explanation and how to check]

### 2. [Question about related code/fixes]
[Explanation and how to check]

[Include 3-5 key questions]

## Diagnostic Code Snippets

[Include code snippets for:]
- Checking relevant state/data
- Adding debug logging
- Testing specific conditions

## Summary of Findings

### Likely Root Cause
[Clear explanation of what's causing the issue]

### Why It's Intermittent
[If applicable, explain timing/conditions]

### Is This a Known Issue?
**[YES/NO]** - [Explanation]
- Link to related issues
- Explain differences from previous reports
- Assess if it's a regression

### Recommendation
[Suggested next steps: file new issue, verify fix, add tests, etc.]
```

### Step 7: Present Findings

**Final message format:**

```
I've completed the investigation into [issue description].

## Key Findings

**Related GitHub Issues:**
- Issue #[NUM] ([open/closed]) - [Brief relevance]
- [2-4 most relevant issues]

**Root Cause:**
[1-2 sentence explanation]

**Status:**
- [NEW BUG / KNOWN ISSUE / REGRESSION / FIXED]
- [Brief justification]

**Critical Code Locations:**
- `path/to/file.ext:lines` - [What's here]
- [2-3 key locations]

I've created a detailed investigation report at [path].

[If new bug:] This appears to be an unreported issue. Would you like me to help create a GitHub issue?

[If known issue:] This is tracked in issue #[NUM]. [Status and any workarounds]

[If regression:] This was fixed in [commit/PR] but appears to have regressed.
```

## Error Handling

**GitHub CLI authentication issues:**
- Try web search as fallback: `WebSearch` with "site:github.com OWNER/REPO [keywords]"
- If both fail: note limitation, proceed with code analysis only

**Can't find repository:**
- Ask user for GitHub URL or owner/repo format
- If user doesn't know: proceed with code analysis, skip issue search

**No related issues found:**
- State clearly: "No similar GitHub issues found"
- Indicate this is likely a new/unreported bug
- Proceed with code analysis and reproduction steps

**Code exploration doesn't find relevant areas:**
- Ask user to identify relevant files or components
- Search for keywords from error messages or symptoms
- Use broader search terms

## Communication Guidelines

**Tone:**
- Technical and precise
- Focus on facts and evidence
- Clear about confidence level (likely, possible, uncertain)
- No unnecessary hedging or apologies

**Do NOT:**
- Speculate without code evidence
- Over-promise on finding the exact cause
- Assume user wants a fix immediately (they asked for investigation)
- Mix investigation with fix proposals (unless explicitly requested)

**DO:**
- Link to specific code lines and GitHub issues
- Show your reasoning with data flow diagrams
- Provide concrete reproduction steps
- Distinguish between confirmed facts and hypotheses
- Cite commit hashes, PRs, and issue numbers
- Be clear about what you found vs. what needs more investigation

## Special Cases

### User has GitHub URL in their message
- Extract owner/repo from URL automatically
- Proceed with issue search immediately

### User mentions specific issue numbers
- Look up those issues first
- Compare symptoms to reported issue
- Determine if it's the same or different

### User says "check if this is fixed"
- Search closed issues for similar symptoms
- Check commit history for relevant fixes
- Verify if fix is in current code at HEAD

### User is on older version
- Check git history between their version and latest
- Identify if issue was fixed after their version
- Recommend updating if fix exists

## Output Files

**Always create:**
- Investigation report markdown file

**Location:**
- Plan mode: Use existing plan file
- Normal mode: `~/.claude/investigations/[repo-name]-[slug].md`

**Format:**
- Markdown with code blocks
- Use proper syntax highlighting
- Include table of contents if long (>500 lines)
- Add frontmatter with date, repo, and symptom keywords
