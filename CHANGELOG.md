# Changelog

## [Unreleased]

### Fixed

- On Windows, a bare command name typed at the dash prompt now runs. Catalog
  programs install as `<name>.exe` and Cosmopolitan appends no suffix while
  searching `PATH`, so `ls` found nothing where `ls.exe` worked; a candidate
  that does not exist is now retried once with `.exe`.

### Changed

- Built by the same compiler as the rest of the catalog. The Linux x86_64
  binary grew from 769 KB to 784 KB; behaviour is unchanged.
