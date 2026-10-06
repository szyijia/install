# Patchwing (un)installer

Installation instructions are available at https://docs.patchwing.net.

## Windows installer

The Windows installer uses the public Git checkout and `pw.bat` bootstrap,
matching the upstream installation model. It requires Windows x64, Git
2.25.1 or newer, and PowerShell 5.1 or newer. It installs for the current user
and updates the user PATH only after bootstrap succeeds.

An existing installation directory is preserved and reported as an error;
the installer does not delete existing SDKs or credentials. Failed clone or
bootstrap results are not reported as successful installation.

Windows distribution is a separate release gate. The presence of this script
does not certify that the website serves it or that matching SDK artifacts
have passed clean-machine acceptance.

## Contributing

Report installer issues in this repository with the operating system,
PowerShell and Git versions, and a sanitized error log. Do not include
credentials or signing keys.

## License

Patchwing projects are licensed for use under either Apache License, Version 2.0
(LICENSE-APACHE or http://www.apache.org/licenses/LICENSE-2.0) MIT license
(LICENSE-MIT or http://opensource.org/licenses/MIT) at your option.

Required upstream copyright and license notices are preserved in this repository.
