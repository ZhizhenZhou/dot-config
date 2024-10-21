#!/bin/zsh

auto_connect() {
	expect -c "
		set timeout 30
		spawn ssh $1
		expect \"*password:\"
		send \"$2\r\"
		send \"\r\"
		interact
	"
}

#user=zhizhzhou6
#hostname=gateway.cs.cityu.edu.hk
#user=platform
#hostname=ss620b.cs.cityu.edu.hk
#server=${user}@${hostname}
#password=Zzz001205
server=620b
password=awFZev3nuU@X

auto_connect ${server} ${password};
