name: Bug Report
description: Create a report to help us improve
title: '[Bug] '
labels: ['bug']
assignees: []

body:
  - type: markdown
    attributes:
      value: |
        ## Description
        Please describe the bug in detail.

  - type: textarea
    id: steps
    attributes:
      label: Steps to Reproduce
      placeholder: |
        1. Go to '...'
        2. Click on '....'
        3. Scroll down to '....'
        4. See error
    validations:
      required: true

  - type: textarea
    id: expected
    attributes:
      label: Expected Behavior
      placeholder: Tell us what you expected to happen
    validations:
      required: true

  - type: textarea
    id: actual
    attributes:
      label: Actual Behavior
      placeholder: Tell us what actually happened
    validations:
      required: true

  - type: input
    id: version
    attributes:
      label: Version
      placeholder: e.g., 2.2.0
    validations:
      required: true

  - type: dropdown
    id: platform
    attributes:
      label: Platform
      options:
        - Android
        - iOS
        - macOS
        - Windows
        - Linux
        - Web
    validations:
      required: true

  - type: textarea
    id: logs
    attributes:
      label: Relevant log output
      placeholder: |
        Paste any relevant log output here

  - type: checkboxes
    id: terms
    attributes:
      label: Checklist
      options:
        - label: I have searched for related issues
          required: true
        - label: I can reproduce the bug with the latest version
          required: true
