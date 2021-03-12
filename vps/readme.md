# VPS setup

Configuration for my VPS. Assumes Debian 10.

1. **Run Ansible.**
  ```
  Run ansible_install.yaml
  ```
2. **Change the root password.**
  ```
  $ passwd root
  ```
4. **Log out, transfer the SSH key(s).**
  ```
  $ ssh-copy-id -i ~/.ssh/<public-key> <username>@<host>
  $ ssh-copy-id -i ~/.ssh/<public-key-git> git@<host>
  ```
5. **Log in as the newly created user.**
  * Change permissions for the authorized keys files.
    ```
    $ sudo chmod 600 /home/<username>/.ssh/authorized_keys
    $ sudo chmod 600 /home/git/.ssh/authorized_keys
    ```
6. **Configure SSH.**
  * The configuration involves changing the default SSH port from 22 to deter
    dumb bots.
  * The settings are based on the [Mozilla OpenSSH
    guidelines](https://infosec.mozilla.org/guidelines/openssh). Only
    non-default settings are included.
  * Copy [sshd_config](sshd_config) to `/etc/ssh/sshd_config` on the server.
    **Do not forget to replace `<NEW-SSH-PORT>` with the correct value and
    `<USERNAME>` with your main account username!**
  * Deactivate short Diffie-Hellman moduli.
    ```
    $ awk '$5 >= 3071' /etc/ssh/moduli \
      | sudo tee /etc/ssh/moduli.tmp > /dev/null \
      && sudo mv /etc/ssh/moduli.tmp /etc/ssh/moduli
    $ sudo service sshd restart
    ```
  * Relog.

7. **Set up a firewall.**
  ```
  $ sudo apt install nftables
  $ sudo systemctl start nftables.service
  $ sudo systemctl enable nftables.service
  ```
  * Copy [nftables.conf](nftables.conf) to `/etc/nftables.conf` on the
    server. **Do not forget to replace `<NEW-SSH-PORT>` with the correct
    value!**
  ```
  $ sudo nft -f /etc/nftables.conf
  ```
8. **Install `fail2ban`.**
  ```
  $ sudo apt install fail2ban
  ```
  * Copy [fail2ban](fail2ban) to `/etc/fail2ban` on the server. **Do not
    forget to replace `<NEW-SSH-PORT>` in [jail.local](fail2ban/jail.local)
    with the correct value!**
    ```
    $ sudo cp /etc/fail2ban/filter.d/apache-badbots.conf \
      /etc/fail2ban/filter.d/nginx-badbots.conf
    ```
  * Check `/etc/fail2ban/action.d/` whether `nftables.conf` exists. If yes,
    replace the `[DEFAULT]` section in [jail.local](fail2ban/jail.local) with
    the following.
    ```
    [DEFAULT]
    banaction = nftables
    banaction_allports = nftables[type=allports]
    ```
  * Start the service.
  ```
  $ sudo systemctl start fail2ban
  $ sudo systemctl enable fail2ban
  $ sudo fail2ban-client status  # Check fail2ban status.
  $ sudo fail2ban-client status sshd  # Check the SSH jail status.
  ```
9. **Enable SSH 2FA.**
  * Make sure that the currently logged user is the one we are setting 2FA
    for.
    ```
    $ sudo apt install libpam-google-authenticator
    $ google-authenticator
    $ sudo cp --archive /etc/pam.d/sshd \
      /etc/pam.d/sshd-COPY-$(date +"%Y%m%d%H%M%S")  # Backup PAM SSH config.
    ```
  * `$ sudo vim /etc/pam.d/sshd`
    * Comment out the `@include common-auth` line.
    * Add `auth required pam_google_authenticator.so` to the bottom of the
      file.
  * `$ sudo vim /etc/ssh/sshd_config`
    * `ChallengeResponseAuthentication yes`
    * `AuthenticationMethods publickey,keyboard-interactive`
    * The first line makes SSH use PAM. The second line requires both the
      SSH key and the verification code -- by default, the SSH key would be
      sufficient.
  * Restart the service.
  ```
  $ sudo service sshd restart
  ```
10. **Enable automatic updates.**
  ```
  $ sudo apt install unattended-upgrades
  ```
  * `$ sudo vim /etc/apt/apt.conf.d/20auto-upgrades`
    ```
    APT::Periodic::Update-Package-Lists "1";
    APT::Periodic::Unattended-Upgrade "1";
    ```
  * `$ sudo vim /etc/apt/apt.conf.d/50unattended-upgrades`
    ```
    Unattended-Upgrade::Origins-Pattern {
        "origin=Debian,codename=${distro_codename},label=Debian-Security";
    };
    ```
11. **Move data**
    copy nextcloud, factorio, csgo files, cronjobs via rsync

12. **run nextcloud**

    create account in cloud.pkubelka.cz
        replace localhost with db
    https://blog.ssdnodes.com/blog/installing-nextcloud-docker/
    After adding files manually - rescan the files
        sudo docker exec --user www-data 5629fb3d44e5 php occ files:scan --all
    Nginx proxy has limit of 2 MB POST request? wtf?
        https://help.nextcloud.com/t/solved-unknown-error-when-uploading-in-web-app-413-request-entity-too-large-when-uploading-through-webdav/69424
        Tady je moje reseni https://github.com/nginx-proxy/nginx-proxy/issues/981#issuecomment-477242873 https://github.com/nginx-proxy/nginx-proxy/issues/981
    https://github.com/nextcloud/docker/issues/261
    https://github.com/nextcloud/docker/issues/95
    1 year old bug with syncing files? wtf? ANother hideous workaround https://github.com/nextcloud/desktop/issues/1035
    mobile app freezes and crashing hard when syncing
    Too many files open: pc version crashes because of syncing small files and app does not close opened files - increase limit for opened files on pc
    https://github.com/nextcloud/desktop/issues/1035
    solution: https://help.nextcloud.com/t/desktop-app-too-many-files-open/85084/3
    “Changes in synchronized folders could not be tracked reliably.”
    “Changes in synchronized folders could not be tracked reliably.”I can’t capture the rest of the message, but to summarize: Files will be synchronized to my nextcloud server every 2 hours.
    https://help.nextcloud.com/t/fedora-30-client-message-changes-in-synchronized-folders-could-not-be-tracked-reliably/57228
    https://docs.nextcloud.com/desktop/2.5/faq.html#there-was-a-warning-about-changes-in-synchronized-folders-not-being-tracked-reliably
    nextcloud,  cloud.de nebo Cirrus jako mobilani appku
    Rclone nextcloud
    zaseknuty grant access https://help.nextcloud.com/t/connection-wizard-is-looping-between-log-in-and-grant-access/46809/6
    seafile
    pustit to jako http ale https zastitit jwilder, delal to nejakej ten kkt na yt takhle
    zkusit to dat dohromady pres 
    https://www.youtube.com/watch?v=GZNuVcx-Akk
    https://nginxproxymanager.com/
    https://download.seafile.com/d/320e8adf90fa43ad8fee/files/?p=/docker/docker-compose.yml
    Nextcloud nema rad slovo "conflict" v nazvech
    Nextcloud zvlada asi sotva utf8
    Je potreba mit unrestricted client max body size pro upload
    FROM jwilder/nginx-proxy:alpine RUN { \ echo 'client_max_body_size 0;'; \ } > /etc/nginx/conf.d/unrestricted_client_body_size.conf

