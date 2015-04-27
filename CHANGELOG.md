# Yo Change Log

All notable changes to this project will be documented in this file. This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased][unreleased]

## [1.0.1] - 2015-04-27
### Added
- License added to all source.
- Add shell script to execute yo (and avoid running if no logged in GUI user).
	- Installed to /usr/local/bin/yo if you use the installer package.

### Changed
- Removed CommandLine.framework and added the source directly to project
	- This avoids needing to have project as a Workspace (although that may be an option in the future).
	- Avoids needing to compile framework individuall and include in project as before.
- Updated readme.

## [1.0] - 2015-03-24
### Added
- Initial commit.

[unreleased]: https://github.com/sheagcraig/yo/compare/1.0.1...HEAD
[1.0.1]: https://github.com/sheagcraig/yo/compare/1.0...1.0.1
