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

| Parameter         | Type   | Description                                                                                     |
|-------------------|--------|-------------------------------------------------------------------------------------------------|
| `git_email`       | String | Email for Git configuration.                                                                     |
| `git_username`    | String | Username for Git configuration.                                                                  |
| `target_repo`     | String | The GitHub repository URL where the documentation resides.                                       |
| `description`     | String | Short description of the package used in indexes etc. Default is an empty string.                |
| `label`           | String | The label that will appear in the sidebar of the docs site. Default is "package-name".           |
| `project_name`    | String | The path where these documents will be located on the docs site. Default is an empty string.     |
| `source_docs_dir`| String | The path to the directory containing the source markdown files. Default is "./docs".              |

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
          source_docs_dir: "./example-docs"
```

### Handling Static Files

In your source repository, static files such as images should be placed in a directory named `_static_` under
your `docs` folder. The directory structure will look like this when you run the `tree` command:

```plaintext
docs/
├── part-one.md
├── part-two.md
└── _static_
└── image.png
```

During the documentation merge process, the orb will automatically move the contents of `_static_` to the appropriate
location in the target repository.

#### Directory Structure Before and After Merge

**Before Merge:**

```plaintext
source-repo/
└── docs/
│ ├── part-one.md
│ └── part-two.md
└── _static_/
    └── image.png
```

**After Merge:**

```
target-repo/
├── docs/
│ └── <<project-name>>
│ ├── part-one.md
│ └── part-two.md
└── static/
    └── <<project-name>>
    └── image.png
```

By following this convention, you ensure that all static files and documents are correctly placed in the target
repository, under `docs/<<project-name>>` for documents and `static/<<project-name>>` for static files.

## Commands

### `clone_target`

#### Description

Clones the target documentation repository to `~/target_repo`.

#### Parameters

| Parameter   | Type   | Description                                                       |
|-------------|--------|-------------------------------------------------------------------|
| `target_repo`| String| The GitHub repository URL where the documentation resides.        |

---

### `commit_and_push`

#### Description

Commits and pushes the updated documentation to the target repository.

#### Parameters

None

---

### `copy_docs_to_target`

#### Description

Clones a Docusaurus repo and adds the docs from the current repo to the target repository.

#### Parameters

| Parameter       | Type   | Description                                                                 |
|-----------------|--------|-----------------------------------------------------------------------------|
| `description`   | String | Short description of the package. Default is an empty string.                |
| `label`         | String | The label for the sidebar. Default is "package-name".                        |
| `project_name`  | String | The path where the documents will be located on the docs site.               |
| `source_docs_dir`| String | The path to the directory containing the source markdown files. Default is "./docs".|
| `target_docs_path`| String | The path to the directory in the target repo where docs will be copied. Default is "./docs".|

---

### `install_git`

#### Description

Installs Git on the CI environment.

#### Parameters

None

---

### `setup_git`

#### Description

Configures Git for commit and push operations.

#### Parameters

| Parameter   | Type   | Description             |
|-------------|--------|-------------------------|
| `git_email`  | String | Email for Git configuration.|
| `git_username`| String | Username for Git configuration.|

---

### `validate_params`

#### Description

Validates that all required parameters are set.

#### Parameters

| Parameter       | Type   | Description                                                                 |
|-----------------|--------|-----------------------------------------------------------------------------|
| `description`   | String | Short description of the package.                                            |
| `git_email`     | String | Email for Git configuration.                                                 |
| `git_username`  | String | Username for Git configuration.                                              |
| `label`         | String | The label for the sidebar.                                                   |
| `project_name`  | String | The path where the documents will be located on the docs site.               |
| `target_repo`   | String | The GitHub repository URL where the documentation resides.                   |
