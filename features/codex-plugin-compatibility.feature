Feature: Native Codex plugin compatibility
  The repository exposes native Codex metadata beside the existing Claude
  metadata. Native hooks reuse the checked-in shared entry points.

  Scenario: Native manifests expose exactly the supported events
    Given the Codex plugin and hook manifests exist
    Then the plugin metadata has real dmj identity and strict semver
    And the hook manifest contains SessionStart and PreToolUse only
    And no UserPromptSubmit or PostToolUse route exists

  Scenario: Windows and POSIX commands route to shared hooks
    Given the native hook manifest is loaded
    Then each route has the exact shared run-hook.cmd command
    And each route has the matching commandWindows command
    And both commands preserve CLAUDE_PLUGIN_ROOT

  Scenario: Shared hooks preserve valid behavior and deny unsafe input
    Given the shared hook runner is invoked
    Then a valid SessionStart response is JSON
    And harmless PreToolUse input has empty output and exit zero
    And the three existing deny policies return valid deny JSON
    And empty or malformed PreToolUse input returns valid deny JSON

  Scenario: Runner and Claude surface integrity are checked
    Given the repository hook files are loaded
    Then invalid runner names fail
    And the runner returns a real child exit code
    And the Claude hook manifest matches its baseline snapshot
    And all plugin versions are equal
