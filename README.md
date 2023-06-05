<h1 align="center">L4D2 Server backup Script</h1>
<h3 align="center">Bash script to backup important server files via SFTP.</h2>

​
<h2 align="center">Known issues/Quirks:</h2>

### If a sourcemod plugin made the backups (on server) to a single folder, we'd fetch that single folder instead of going folder by folder/file by file but I haven't wrote said plugin yet.
### Ideally, your provider should allow you to authenticate to SFTP using an SSH key, that way the process can be entirely automated, otherwise you need to input your SFTP password each time a new SFTP session is started (14 times in this script or 1 time if/when I write the on-server backup plugin).
