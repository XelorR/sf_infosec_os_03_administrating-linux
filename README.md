# OS 03. Administrating GNU Linux

## todo

- [x] run apache
- [ ] install and enable ftp
- [ ] install and enable window manager and rdp
- [ ] implement backup with tar and cron (alternatively with systemd and tar)
- [ ] implement logging

## [Rollout](./rollout.sh)

```bash
# run directly form server:
curl https://raw.githubusercontent.com/XelorR/sf_infosec_os_03_administrating-linux/main/rollout.sh | bash -
```

SSH will be enabled, then You will be able to connect:
![ssh - login successful](./assets/ssh-login-successful.png)

if backports block commented by some reason, backports.sources will be created in /etc/apt/sources.list.d/
![sources add](./assets/sources-list.png)

Apache will be automatickly enabled:
![apache is running](./assets/apache-is-running.png)

## [Backup](./backup.sh)

## [Logging](./setup-logging.sh)
