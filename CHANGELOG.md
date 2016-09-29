# Yo Change Log

All notable changes to this project will be documented in this file. This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased][unreleased]

### Changed
- Updated to Swift 3 syntax.
- Updated to a fork of CommandLine (IngmarStein's PR to update for Xcode8/Swift3)

### Added
- New yo.py launcher (package installer puts it at `/usr/local/bin/yo`).
- New Yo launch system! LaunchDaemon and two LaunchAgents to allow reliable
  notification triggering by the management tool of your choice. Thanks to
  @chilcote and @grahamgilbert for the inspiration and technical assistance.

### Removed
- Removed casper directory in lieue of new launcher script system.
- Removed yo.sh.

## [1.0.3] - 2015-08-22 - Prince's Hair in Purple Rain
### Fixed
- Yo now properly uses the BundleIdentifier rather than the string literal `org.da.yo`. Thanks for the spot @mcfly1976. (#6)

## [1.0.2] - 2015-04-28 - Tina Turner's Hair in Mad Max Beyond Thunderdome
### Added
- Ability to execute bash scripts using the `-B/--bash-action` argument.

### Changed
- Clarified instructions for specifying sounds.
- Defaults to using the default notification sound now.
- If you set a sound to None, i.e. `-z None` there will be no sound.

## [1.0.1] - 2015-04-27 - David Bowie's Hair in the Movie Labyrinth
### Added
- License added to all source.
- Add shell script to execute yo (and avoid running if no logged in GUI user).
	- Installed to /usr/local/bin/yo if you use the installer package.

### Changed
- Removed CommandLine.framework and added the source directly to project
	- This avoids needing to have project as a Workspace (although that may be an option in the future).
	- Avoids needing to compile framework individually and include in project as before.
- Updated readme.

## [1.0] - 2015-03-24
### Added
- Initial commit.

[unreleased]: https://github.com/sheagcraig/yo/compare/1.0.3...HEAD
[1.0.3]: https://github.com/sheagcraig/yo/compare/1.0.2...1.0.3
[1.0.2]: https://github.com/sheagcraig/yo/compare/1.0.1...1.0.2
[1.0.1]: https://github.com/sheagcraig/yo/compare/1.0...1.0.1
