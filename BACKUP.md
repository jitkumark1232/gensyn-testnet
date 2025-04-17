### 1. Back up `swarm.pem` from GPU server to local PC
- For this, you must need to connect to GPU server using [SSH](https://github.com/zunxbt/gensyn-testnet?tab=readme-ov-file#-connect-via-ssh) (Recommened to do these stuffs on Command Prompt or Power Shell)
- Now exit from this GPU server using this command
```
exit
```
- Now replace `SSH-COMMAND` in the below command with the command which your received from provider, then replace `YOUR-PC-PATH` where you want to download this swarm.pem file and then execute it on your Command prompt or Power shell
```
SSH-COMMAND "cat ~/rl-swarm/swarm.pem" > "YOUR-PC-PATH\swarm.pem"
```
- In my case, this command looks like this :
```
ssh -p 69 root@69.69.69.69 "cat ~/rl-swarm/swarm.pem" > "C:\Users\USER\Downloads\swarm.pem"
```
- Done, your `swarm.pem` file is now saved on your local system

### 2. Back up `swarm.pem` from VPS server to local PC
- For this, I recommend to use `Command Prompt` or `Power Shell`
- If you are using **Command Prompt** then use the below commmand, make sure to replace `VPS-USERNAME` , `VPS-IP`and `YOUR-PC-PATH` (where you want to save swarm.pem file) with actual value
```
scp VPS-USERNAME@VPS-IP:~/rl-swarm/swarm.pem "YOUR-PC-PATH"
```
- In my case this command looks like this :
```
scp root@69.69.69.69:~/rl-swarm/swarm.pem "C:\Users\USER\Downloads"
```
- If you are using **Powershell** then use the below commmand, make sure to replace `VPS-USERNAME` , `VPS-IP`and `YOUR-PC-PATH`(where you want to save swarm.pem file) with actual value
```
scp VPS-USERNAME@VPS-IP:~/rl-swarm/swarm.pem 'YOUR-PC-PATH'
```
- In my case this command looks like this :
```
scp root@69.69.69.69:~/rl-swarm/swarm.pem 'C:\Users\USER\Downloads'
```

### 3. Back up `swarm.pem` from WSL to local PC
- First, open `Command Prompt` or `Windows Powershell`
- Then use the below command, make sure to replace `YOUR-WSL-USERNAME` `YOUR-PC-PATH`(where you want to save swarm.pem file) with actual value
```
copy "\\wsl$\Ubuntu\home\YOUR-WSL-USERNAME\rl-swarm\swarm.pem" "YOUR-PC-PATH"
```
- In my case, it looks like this
```
copy "\\wsl$\Ubuntu\home\zun24\rl-swarm\swarm.pem" "C:\Users\USER\Downloads"
```
