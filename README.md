<h1 align="center">L4D2 Server Backup Script</h1>
<h3 align="center">Bash script to automatically backup important server files via SFTP.</h2>
​

<h2 align="center">Purpose:</h2>

The purpose of this script is to create a backup of important files/folders on your dedicated Left 4 Dead 2 server by fetching them using SFTP, and then committing and pushing them to a Git repository. Useful for backup purposes or for migrating to a new service provider/cloning your Left 4 Dead 2 server.
​

<h2 align="center">Requirements</h2>

- A Linux machine —I recommend to use a minimal virtual machine with a TTY interface, which can be set up using a server setup tool like Arch Linux's [archinstall](https://wiki.archlinux.org/title/Archinstall). This approach is ideal for running the script without any performance downsides, even on a machine with just 512MB RAM and 1 core. (Assuming you're comfortable with TTY)—
- [expect](https://man.archlinux.org/man/expect.1)
- [git](https://archlinux.org/packages/extra/x86_64/git/) configured with your [user.name and user.email](https://git-scm.com/book/en/v2/Getting-Started-First-Time-Git-Setup)
- [github-cli](https://archlinux.org/packages/extra/x86_64/github-cli/) configured to [cache your credentials via HTTPS](https://docs.github.com/en/get-started/getting-started-with-git/caching-your-github-credentials-in-git), or use SSH
- SFTP access to your remote server
- Your remote server does not allow SSHing/SSH key authentication for SFTP (if it does, adjust accordingly to mitigate security risks).
- Connect to your remote server using SFTP manually at least once and accept the key fingerprint.
​
    
<h2 align="center">Usage</h2>

- Create a new "l4d2-server-backup" repository with your git provider to store the backups and clone it to your machine's home directory
```
git clone https://github.com/YourUsername/l4d2-server-backup.git
```

- Clone the repository and place the script in your home folder:
```
git clone https://github.com/TestieTendie/l4d2-server-backup-script.git
cd ./l4d2-server-backup-script/
mv l4d2-server-backup.sh ~/l4d2-server-backup.sh
cd ~
```

- Open the script file using a text editor and update the **SERVER**, **PORT**, **USERNAME** and **PASSWORD** fields with your own remote server information, don't forget to **locate the "USER@SERVER's password:"** lines and **replace the values there too**.

- Ensure the script is marked as an executable 
```
chmod +x ./l4d2-server-backup.sh
```

- Run the script:
```
./l4d2-server-backup.sh
```

- The script creates a backup copy of your server files in the ~/l4d2-server-backup directory, which is committed and pushed to the Git repository.
- Unlike [rsync](https://wiki.archlinux.org/title/Rsync), which can keep a 1:1 copy in your local machine, sftp is not able to detect and remove files that were deleted from the server. Therefore, once commited and pushed, the script deletes the backup copy from your local machine to avoid keeping outdated files.
​

<h2 align="center">How to Automate (Scheduling)</h2>

To schedule this script to run at specified intervals, you can use [cron](https://wiki.archlinux.org/title/Cron) (Not included by default in Arch Linux but might be on other distros) or [systemd/Timers](https://wiki.archlinux.org/title/Systemd/Timers) (Included by default). 
​

<h4>Here's how you can schedule a job to run every 30 minutes past the hour using `cron`:</h4>

1. Open the crontab file using the following command:

```
crontab -e
```

2. Add the following line to the bottom of the file:

```
30 * * * * /path/to/your/script.sh
```

Each * in a cron schedule represents a wildcard or catch-all value that matches any value. Each * in a cron schedule represents:

    The first * represents the minute (0-59)
    The second * represents the hour (0-23)
    The third * represents the day of the month (1-31)
    The fourth * represents the month (1-12)
    The fifth * represents the day of the week (0-6, where 0 is Sunday)

So, using 30 * * * * in a cron schedule means "run the command at 30 minutes past every hour, every day, every month, and every day of the week."

Conversely, to schedule it to run every day at say 3pm using cron, you can use the following schedule: 0 15 * * *.
​

<h3>Here's how you can schedule a job to run every 30 minutes using `systemd/Timers`:</h3>

1. Create a new service file (`l4d2-server-backup.service`) in `~/.config/systemd/user`:

```
[Unit]
Description=L4D2 Server Backup

[Service]
Type=simple
ExecStart=/home/<username>/l4d2-server-backup.sh

[Install]
WantedBy=default.target
```
#### Make sure to replace `<username>` with your account's username

2. Create a new timer file (`l4d2-server-backup.timer`) in `~/.config/systemd/user`:

```
[Unit]
Description=L4D2 Server Backup

[Timer]
OnCalendar=*:0/30

[Install]
WantedBy=timers.target
```

This will schedule the script to run every 30 minutes.

Conversely, to schedule it to run every day at say 3pm using systemd/Timers, you can use the following under [Timer]: `OnCalendar=*-*-* 15:00:00.`

3. Enable and start the service:

```
systemctl --user enable --now l4d2-server-backup.service
```
This will start the service immediately and program it to start on every boot.

4. Enable and start the timer:

```
systemctl --user enable --now l4d2-server-backup.timer
```
​
Sure, here's a section you can add to the instructions:

<h3 align="center">Important Reminder</h3>

Before you deploy the scheduled job for the first time, it's important that you connect to your remote server manually using SFTP at least once and accept the key fingerprint.

When you connect to your server for the first time using SFTP, you'll be prompted to accept the key fingerprint. By accepting the key fingerprint, you're verifying that you trust the server and allowing your SFTP client to establish the connection.

If you don't accept the key fingerprint manually before deploying the scheduled job, the script will fail to connect to the remote server when it runs, and the backups won't be created.

To connect manually using SFTP, you can use the following command in your terminal:

```
sftp user@server_ip
```

Replace `user` with your remote server username and `server_ip` with your remote server's IP address. After running the command, you'll be prompted to enter your password and accept the key fingerprint.

Once you've connected to the remote server and accepted the key fingerprint, you can go ahead and deploy the scheduled job as detailed above.
​

<h2 align="center">Known Issues/Risks</h2>

Using this script poses some risks, mainly storing the SFTP password in plain text. Remember that you should **ALWAYS** use strong, random passwords, **NEVER AND I MEAN NEVER, EVER REUSE PASSWORDS**, store them in vaults and update them **(AND your machine)** frequently.

Depending on your level of paranoia, you could create a service and timer that enables and disables network access for your device automatically, thereby reducing the risk of any potential exposure but I personally consider it overkill since the machine does not contain any important information.
​

<h2 align="center">Reasons to do it this way</h2>

This approach offers a technique to automatically create backups of your Left 4 Dead 2 server files in situations where your provider doesn't allow SSHing or SSH key authentication for SFTP. However, if your provider does allow SSH key authentication for SFTP, you must always authenticate using an SSH key as it is a secure method that does not require passwords.
​

<h2 align="center">Reasons to NOT do it this way</h2>

The reader should be aware that this approach may not be suitable for all scenarios, and they should review their provider's policies and practices to determine the most appropriate method for their needs.
​

<h2 align="center">License</h2>

The code and instructions provided in this repository are licensed under the MIT License, a permissive open-source license that allows for reuse and modification of the code. The reader should review the full text of the MIT License to understand their rights and obligations when using or modifying the code provided.
​

<h2 align="center">Disclaimer</h2>

This repository provides instructions for educational purposes only, and the reader assumes all responsibility and liability for their use of any information provided in this repository, including any code or instructions. The author assumes no responsibility or liability for any errors or omissions, or for any damages or consequences that may result from the use of the information provided. Note that this repository is provided without any warranty or guarantee of any kind. Any reliance on this information is at the reader's own risk
