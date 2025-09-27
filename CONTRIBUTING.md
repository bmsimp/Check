# Contributing to Check

Thanks for taking the time to contribute! These guidelines help keep contributions consistent and reliable for this Chrome extension.

## Development Setup
- Fork the repository and clone your fork.
- In Chrome or a Chromium-based browser, open `chrome://extensions`.
- Enable **Developer mode** and choose **Load unpacked**.
- Select the repository root to load the extension. Reload the extension after making changes.

## Coding Standards (ESLint)
- No ESLint configuration is committed to the repository. Maintain the existing code style (2 spaces, semicolons, ES modules).
- If you have ESLint installed locally, run `npx eslint scripts options popup` with the default recommended rules and resolve any issues before committing.

## Commit Style
- Use [Conventional Commits](https://www.conventionalcommits.org/) such as `feat:`, `fix:`, or `docs:` to describe your changes.
- Keep commits focused and concise.

## Testing Expectations
- Automated tests are not currently available. Manually test changes by loading the extension and verifying:
  - The background service worker initializes without errors.
  - Content scripts inject and execute as expected.
  - Options and popup pages function correctly.
- Include a brief summary of manual testing in your pull request.

## Scripted Deployment Updates
- Any new configuration settings result in a need to be managed by scripted deployment. As such, the following files need to be reviewed and have the settings added:
  - [enterprise/Deploy-Windows-Chrome-and-Edge.ps1](enterprise/Deploy-Windows-Chrome-and-Edge.ps1)
  - [enterprise/admx/Check-Extension.admx](enterprise/admx/Check-Extension.admx)
  - [enterprise/admx/en-US/Check-Extension.adml](enterprise/admx/en-US/Check-Extension.adml)

## Reporting Security Issues

Security vulnerabilities should be reported privately. Refer to [SECURITY.md](SECURITY.md) for disclosure instructions instead of opening public issues or pull requests.

## Pull Request Workflow
1. Create a topic branch from `main`.
2. Make your changes and commit them following the guidelines above.
3. Ensure manual tests pass and any ESLint checks you run are clean.
4. Push your branch and open a pull request describing the changes and test results.
5. Address review feedback and update your pull request as needed.

## Documentation Expectations
- When updating or creating a feature, the corresponding documentation in [docs](docs) should also be updated to reflect your code changes.
- The documentation hosted at [https:docs.check.tech](https:docs.check.tech) utilizes GitBook which uses mostly GitHub Markdown with some additional syntax. Commit the changes in pure GitHub Markdown while leaving any GitBook sytax in place.
- New settings should also be added to [config/managed_schema.json](config/managed_schema.json) as this is a central reference for all other documentation
