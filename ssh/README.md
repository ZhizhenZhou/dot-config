# ssh-config
## Install ssh
## Import config
Generating Keys:
```
ssh-keygen -t rsa
```
Then append local `~/.ssh/id_rsa.pub` to remote file `~/.ssh/authorized_keys`.

Now import configuration.
```
curl -L -o ~/.ssh/config https://raw.githubusercontent.com/ZhizhenZhou/dot-config/refs/heads/main/ssh/config
```

```
curl -L -o ~/autossh.sh https://raw.githubusercontent.com/ZhizhenZhou/dot-config/refs/heads/main/ssh/autossh.sh
```
