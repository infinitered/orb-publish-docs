# Orb Template

<!---
[![CircleCI Build Status](https://circleci.com/gh/infinitered/publish-docs.svg?style=shield "CircleCI Build Status")](https://circleci.com/gh/<organization>/<project-name>) [![CircleCI Orb Version](https://badges.circleci.com/orbs/<namespace>/<orb-name>.svg)](https://circleci.com/developer/orbs/orb/<namespace>/<orb-name>) [![GitHub License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/<organization>/<project-name>/master/LICENSE) [![CircleCI Community](https://img.shields.io/badge/community-CircleCI%20Discuss-343434.svg)](https://discuss.circleci.com/c/ecosystem/orbs)

--->

# Publish Docs Orb

## Overview

This orb automates the process of merging Docusaurus documentation from multiple repositories into a single target
repository.

## What It Does

1. **Clone Target Repository**: Clones the target Docusaurus documentation repository to the CI environment.
2. **Check for Docs**: Verifies that documentation files exist in the source repository.
3. **Copy Docs**: Copies documentation from the source repository to the cloned target repository.
4. **Move Static Content**: Moves any static content to the appropriate directory in the target repository.
5. **Generate _category_.json**: Creates a `_category_.json` file for new documentation sections.
6. **Commit and Push**: Commits the changes and pushes them to the target repository.

## Features

- Streamlined documentation consolidation
- Configurable paths and labels
- Automatic `_category_.json` creation

## Prerequisites

- CircleCI account
- A Docusaurus documentation repository

## Parameters

- `git_email` (String): Email for Git configuration.
- `git_username` (String): Username for Git configuration.
- `target_repo` (String): The GitHub repository URL where the documentation resides.
- `description` (String): Short description of the package used in indexes etc. (Default: "")
- `label` (String): The label that will appear in the sidebar. (Default: "package-name")
- `project_name` (String): The path where documents will be located on the docs site. (Default: "")
- `source_docs_path` (String): The path to the source docs directory. (Default: "./docs")

## Basic Example

Here's a simple example demonstrating how to use the orb:

```yaml
version: 2.1

orbs:
  publish-docs: infinitered/publish-docs@x.y.z  # replace with current version

workflows:
  publish-my-docs:
    jobs:
      - publish-docs/publish_docs:
          git_email: "your-email@example.com"
          git_username: "Your Username"
          target_repo: "https://github.com/your-org/your-docs-repo.git"
          description: "An example package."
          label: "Example Package"
          project_name: "example-package"
          source_docs_path: "./example-docs"
```
