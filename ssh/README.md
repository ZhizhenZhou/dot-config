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
curl -L0 ~/.ssh/ https://raw.githubusercontent.com/ZhizhenZhou/dot-config/refs/heads/main/ssh/config
```

```
curl -L0 ~/ https://raw.githubusercontent.com/ZhizhenZhou/dot-config/refs/heads/main/ssh/autossh.sh
```
