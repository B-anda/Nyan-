# My Project GitLab CI/CD Configuration

This repository contains the GitLab CI/CD configuration for Nyan project. This configuration defines various stages and jobs to automate the build, test, and deployment process.

## Configuration Overview

### Environment

The CI/CD pipeline uses the `ruby:2.7.4` Docker image as the base environment for running jobs.

### Variables

The following variables are defined for use in the pipeline:

- `TEST_PATH`: Specifies the directory containing test files.
- `TEST_FILES`: Specifies the path to the test files.

### Stages

The pipeline is organized into the following stages:

1. **build**: Stage for building the project.
2. **test**: Stage for running tests.
3. **deploy**: Stage for deploying the project.

## Jobs

### Build

- **Stage**: build
- **Script**: Installs project dependencies using Bundler.

### Test: Conditions

- **Stage**: test
- **Script**: Runs tests defined in `testConditions.rb` located in the `$TEST_PATH` directory.

### Test: Scope

- **Stage**: test
- **Script**: Runs tests defined in `testScope.rb` located in the `$TEST_PATH` directory.

### Test: Syntaxtree

- **Stage**: test
- **Script**: Runs tests defined in `testSyntaxtree.rb` located in the `$TEST_PATH` directory.

### Deploy: Nyan Conditions

- **Stage**: deploy
- **Script**: Placeholder script for deploying the project.

## Before Script

- Installs Bundler version 2.4.22 before running any job.
