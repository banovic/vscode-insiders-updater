Script that keeps Visual Studio Code Insiders edition updated on Slackware.

It is useful for keeping up-to-date with high-frequency-release extensions like Claude Code, rust-analyzer, etc.

It will install or update VSCode Insiders, which seems to be released daily.
By default daily cron task is created (/etc/cron.daily/vscode-insiders-updater-cron.sh), but you can run it directly as root:

```
/opt/vscode-insiders-updater/vscode-insiders-updater.sh
```

Script will then install or update VSCode Insiders edition, or do nothing if you already have most recent release.

Scripts determines available VSCode Insiders version (timestamp) by making HEAD request and looking into `Content-Disposition` header and then parsing version from it. This does not download the whole file, but still makes a network request.
After that it calls `SlackBuild/vscode-insiders.SlackBuild` to make and install new package, or does nothing if latest version is already installed.

If flag `--reinstall` is passed VSCode Insiders will be reinstalled regardless of current version.
