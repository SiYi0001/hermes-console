name: Feature Request
description: Suggest a new feature for HermesConsole
title: '[Feature] '
labels: ['enhancement']
assignees: []

body:
  - type: markdown
    attributes:
      value: |
        ## Feature Description
        Please describe the feature you'd like to request.

  - type: textarea
    id: problem
    attributes:
      label: Problem Statement
      placeholder: |
        Describe the problem this feature would solve
    validations:
      required: true

  - type: textarea
    id: solution
    attributes:
      label: Proposed Solution
      placeholder: |
        Describe your proposed solution
    validations:
      required: true

  - type: textarea
    id: alternatives
    attributes:
      label: Alternatives Considered
      placeholder: |
        Describe any alternative solutions you've considered

  - type: textarea
    id: mockups
    attributes:
      label: Mockups / Screenshots
      placeholder: |
        If applicable, add mockups or screenshots here

  - type: checkboxes
    id: checklist
    attributes:
      label: Checklist
      options:
        - label: This is a new feature request
          required: true
        - label: I've searched existing issues
          required: true
        - label: I understand this feature requires implementation effort
          required: true
