# Claude Code Session Context Profile

**PRIMARY REFERENCE**: This session follows all patterns, workflows, and requirements defined in `/workspaces/kinda-lang-agents/agents/coder.md`

## Key User Requirements (from coder.md)
- **CRITICAL**: Never commit to main - always use feature branches targeting `dev` (NOT main!)
- **GitFlow**: feature → dev → release → main (dev is integration branch)
- **Testing**: Comprehensive test coverage is mandatory for all changes
- **Code Reviewer**: Always use reviewer agent before merging
- **Pre-commit**: Must run full test suite and verify CI is passing before any commits
- **ACTUAL TARGET BRANCH**: `dev` (confirmed by user - this repo uses dev instead of develop)

## Current Session Work (2025-08-27)
- **Issue #59**: Fix ~ish integration syntax limitations
- **Problem**: `~maybe (var ~ish value)` was generating invalid Python syntax
- **Solution**: Implemented balanced parentheses parsing for conditional matchers in `/workspaces/kinda-lang/kinda/grammar/python/matchers.py`
- **Status**: COMPLETED - fix implemented and tested
- **Branch**: feature/issue-59-ish-integration-fix
- **Files modified**:
  - `kinda/grammar/python/matchers.py` - Added balanced parentheses parsing
  - `examples/python/comprehensive/chaos_arena_complete.py.knda` - Updated to use improved syntax
  - `examples/python/individual/ish_integration_showcase.py.knda` - New showcase example

## Recent Completed Work
1. ✅ Issue #41: Test coverage (94% achieved)
2. ✅ Issue #58: Comprehensive examples showcase
3. ✅ Issue #63: Documentation infrastructure with GitHub Pages
4. ✅ Issue #59: ~ish integration syntax improvements (CURRENT SESSION)

## Next Priorities (from ROADMAP.md)
1. Performance optimizations
2. Re-enable ~welp construct (complete testing)
3. Enhanced chaos constructs (`~yolo`, `~oops`, `~meh`)
4. Personality profile system