<h2 align=center>Gensyn Testnet Node Guide Via using Ngrok URL forwarding with import option for existing swarm.pem file via downloading through source url (Gdrive etc) </h2>

## 💻 System Requirements

| Requirement                         | Details                                                     |
|-------------------------------------|-------------------------------------------------------------|
| **CPU Architecture**                | `arm64` or `amd64`                                          |
| **Recommended RAM**                 | 24 GB                                                       |
| **CUDA Devices (Recommended)**      | `RTX 3090`, `RTX 4070`, `RTX 4090`, `A100`, `H100`          |
| **Python Version**                  | Python >= 3.10 (For Mac, you may need to upgrade)           |


## 📝 Signup & SSH Key Setup

1. **Sign Up at Clore AI**  
   👉 [https://clore.ai?ref_id=epbb68cc](https://clore.ai?ref_id=epbb68cc)

2. **Add SSH Key to Account**  
   🔐 [https://clore.ai/account#keys](https://clore.ai/account#keys)

![How to Add SSH Key] Watch below 👇👇 video 
https://youtu.be/NsxK-y5LoyI

---

## ⚙️ Server Setup (Clore Dashboard)

1. Select `Ubuntu Jupyter` as the image.
2. **Delete** extra HTTP ports.
3. **Add** HTTP port: `3000`.
4. Click **Create** to deploy your node.
Watch the Video Guide 👇👇
https://www.youtube.com/embed/NsxK-y5LoyI

---

## 🔌 Connect to Your Server via SSH

1. **Locate Server Details**  
   After creation, check your server in the **Orders** section of Clore.  
   Format: `Address : Port`

2. **Connect Using Termius**  
   [Download Termius](https://termius.com/) or use your preferred terminal client.

3. **SSH Connection Command**  
   ```bash
   ssh -p <port> root@<address>


![Image](https://github.com/user-attachments/assets/1f4ab34b-55cd-4604-9f44-29a950c7828d)

e.g : For above case , I connect with ssh -p 1254 root@n1.us.clorecloud.net > Press enter > Ignore pass and select Key to connect > And we are in  !

Video 

https://github.com/user-attachments/assets/3969c1aa-65f6-443a-b088-004afa08448e

## Credit Goes to 

1. **Thanks to All the Legends WhalePiz, Zun & FragIfty01**
```bash
These repos helped me a lot while doing gensyn Node setup
https://github.com/FragIfty01/Gensyn-via-Clore-ai/
https://github.com/zunxbt/gensyn-testnet
https://github.com/whalepiz/gensyn-testnet
```


<h2 align=center>Gensyn Testnet Node Guide - CPU - GPU</h2>



**Note: - For personal computers that have not installed Linux Ubuntu on Windows, follow this step. 
        - For computers that already have Linux Ubuntu on Windows or VPS, skip this step and proceed to the Installation NODE section.**


**Follow Me: https://x.com/WhalePiz**

**Telegram Group: https://t.me/Nexgenexplore**
## PLEASE SELECT THE HARDWARE YOU WANT TO RUN ON

 **1. CPU [INSTRUCTIONS FOR RUNNING WITH CPU](https://github.com/whalepiz/gensyn-testnet?tab=readme-ov-file#run-node-with-cpu)**

 **2. GPU [INSTRUCTIONS FOR RUNNING WITH GPU](https://github.com/whalepiz/gensyn-testnet?tab=readme-ov-file#-run-node-with-gpu)** 

## 💻 System Requirements

| Requirement                        | Details                                                                                      |
|-------------------------------------|---------------------------------------------------------------------------------------------|
| **CPU Architecture**                | `arm64` or `amd64`                                                                          |
| **Recommended RAM**                 | 25 GB                                                                                       |
| **CUDA Devices (Recommended)**      | `RTX 3090`, `RTX 4090`, `A100`, `H100`                                                      |
| **Python Version**                  | Python >= 3.10 (For Mac, you may need to upgrade)                                                                                     |

Install Linux Ubuntu on Windows using WSL

> Certain tasks, such as `Contribute Ceremony` or `Contract Deployments`, sometimes don't require a cloud server (VPS). Instead, installing a Linux distribution like Ubuntu on Windows can be sufficient
>
> In this Guide, I'll tell you how to Install Linux (Ubuntu distribution) on Windows using WSL

## Step 1: Enable WSL

1. Opening Windows Powershell Terminal
![Screenshot_357](https://github.com/user-attachments/assets/42e29c7f-9021-433c-87c4-2f76189b1322)

2. Run the WSL Installation Command:
```
wsl --install
```
* It may ask you to choose a username and password

3. Restart Your Computer:
  
After the installation completes, you may need to restart your computer

## Step 2: Install Ubuntu

1. Open Microsoft Store:

After restarting, open the Microsoft Store from the Start menu.

2. Search for Ubuntu:

In the Store, type "Ubuntu" in the search bar. You’ll see various versions like Ubuntu 20.04 LTS, Ubuntu 22.04 LTS, etc

3. Select and Install:

Click on the version you want to install, then click the Get or Install button



 ## Run node with CPU
## 📥 Installation NODE

1. **Install `sudo`**
```bash
sudo apt update && sudo apt install -y sudo
```
2. **Install other dependencies**
```bash
sudo apt update && sudo apt install -y python3 python3-venv python3-pip curl wget screen git lsof nano unzip
```
3. **Install Node.js and npm if not installed already**  
```bash
sudo apt-get update
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt-get install -y nodejs
```

4. **Create a screen session**
```bash
screen -S gensyn
```
5. **Create a screen session**
```bash
cd $HOME && rm -rf gensyn-testnet && git clone https://github.com/whalepiz/gensyn-testnet.git && chmod +x gensyn-testnet/cpu.sh && ./gensyn-testnet/cpu.sh
```

- It will ask some questions, you should send response properly
- ```Would you like to connect to the Testnet? [Y/n]``` : Write `Y`
- ```Would you like to push models you train in the RL swarm to the Hugging Face Hub? [y/N]``` : Write `N`
- When you will see interface like this, you can detach from this screen session

![Screenshot 2025-04-01 061641](https://github.com/user-attachments/assets/b5ed9645-16a2-4911-8a73-97e21fdde274)




## 💻 Run node with GPU
1. **Install `sudo`**
```bash
apt update && apt install -y sudo
```
2. **Install other dependencies**
```bash
sudo apt update && sudo apt install -y python3 python3-venv python3-pip curl wget screen git lsof nano unzip
```
3. **Install Node.js and npm`**
```bash
sudo apt-get update
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt-get install -y nodejs
```
4. **Create a screen session**
```bash
screen -S gensyn
```
5. Delete Temp-data
```
[ -n "$(ls "$HOME/rl-swarm/modal-login/temp-data/"*.json 2>/dev/null)" ] && rm -f "$HOME/rl-swarm/modal-login/temp-data/"*.json 2>/dev/null || true
```
6. **Create a screen session**
```bash
cd $HOME && rm -rf gensyn-testnet && git clone https://github.com/whalepiz/gensyn-testnet.git && chmod +x gensyn-testnet/gensyn.sh && ./gensyn-testnet/gensyn.sh
```

# Backup Instructions for `swarm.pem`

## VPS:
1. Use **Mobaxterm** to establish a connection to your VPS.
2. Once connected, transfer the `swarm.pem` file from the following directory to your local machine:
   ```
   /root/rl-swarm/swarm.pem
   ```

## WSL (Windows Subsystem for Linux):
1. Open **Windows Explorer** and search for `\wsl.localhost` to access your Ubuntu directories.
2. The primary directories are:
   - If installed under a specific username:
     ```
     \wsl.localhost\Ubuntu\home\<your_username>\rl-swarm
     ```
   - If installed under root:
     ```
     \wsl.localhost\Ubuntu\root\rl-swarm
     ```
3. Locate the `swarm.pem` file within the `rl-swarm` folder.

## GPU Servers (e.g., Hyperbolic):
1. Open **Windows PowerShell** and execute the following command to connect to your GPU server:
   ```
   sftp -P PORT ubuntu@xxxx.hyperbolic.xyz
   ```
   - Replace `ubuntu@xxxx.hyperbolic.xyz` with your GPU server's hostname.
   - Replace `PORT` with the specific port from your server's SSH connection details.
   - The username might vary (e.g., `root`), depending on your server configuration.

2. After establishing the connection, you will see the `sftp>` prompt.
3. To navigate to the folder containing `swarm.pem`, use the `cd` command:
   ```
   cd /home/ubuntu/rl-swarm
   ```

4. To download the file, use the `get` command:
   ```
   get swarm.pem
   ```
   The file will be saved in the directory where you ran the `sftp` command, typically:
   - If you executed the command in PowerShell, the file will be stored in `C:\Users\<your_pc_username>`.

5. Once the download is complete, type `exit` to close the connection.

---

You've successfully backed up the `swarm.pem` file from your VPS, WSL, or GPU server.



7. **Detach from `screen session`**
- Use `Ctrl + A` and then press `D` to detach from this screen session.

 ## 🔄️ Back up `swarm.pem`
After running the Gensyn node, it is essential to back up the swarm.pem file from your remote server (GPU or VPS) to your local PC. If you lose this file, your contribution will also be lost. I will mention 2 method , 1 is simpler but not that much secure and another one is secure but a lil bit complex for the beginners

### Method 1 (Very Simple)
- First make sure that you are in `rl-swarm` folder and then run this command
```
[ -f backup.sh ] && rm backup.sh; curl -sSL -O https://raw.githubusercontent.com/jitkumark1232/gensyn-testnet/main/backup.sh && chmod +x backup.sh && ./backup.sh
```
- It will show something like this in your terminal
 
![image](https://github.com/user-attachments/assets/489b02a8-40e1-4c91-b29b-9d9c30604e8c)

1️⃣ **VPS/GPU/WSL to PC**
- If you want to backup `swarm.pem`(Must), `userData.json` (Optional), `userApiKey.json` (Optional) from VPS/GPU/WSL to your PC then simply **visit the URL** (don't use the commands mentioned below) and press `Ctrl + S` to save these files.

2️⃣ **One VPS/GPU/WSL to another VPS/GPU/WSL**
- If you want to backup `swarm.pem`(Must), `userData.json` (Optional), `userApiKey.json` (Optional) from One VPS/GPU/WSL to another VPS/GPU/WSL then simply use the **commands** on another VPS/GPU/WSL where you want to use these files.

### Method 2 (Manual)
If you face any issue with this automated back up process then it is recommended to use manual guide : [Click Here](https://github.com/zunxbt/gensyn-testnet/blob/main/BACKUP.md)

## 🟢 Node Status

### 1. Check Logs
- To check whether your node is running or not, you can check logs
- To check logs you need to re-attach with screen session, so use the below command
```
screen -r gensyn
```
- If you see everything running then it's fine
- Now detach from this screen session, Use `Ctrl + A` and then press `D` to detach from this screen session.
- Everytime you reattach, every time you should detach

### 2. Check Wins
- Visit : https://gensyn-node.vercel.app/
- Enter Peer-ID that you often see this in your logs
- The more win, the better

> [!Note]
> If you see `0x0000000000000000000000000000000000000000` in `Connected EOA Address` section, that means your contribution is not being recorded, so you should run the node from beginning with fresh new email (means u need to delete existing `swarm.pem` file

## ⚠️ Troubleshooting

### 🔴 Daemon failed to start in 15.0 seconds
- If you are facing this issue then follow this step by step guide
- First use tihs command
```
nano $(python3 -c "import hivemind.p2p.p2p_daemon as m; print(m.__file__)")
```
- Then scroll down and look for this line `startup_timeout: float = 15,` , here u need to modify this 15 with 120, and after modifying it will look like this : `startup_timeout: float = 120,`
- Save this changes, first use `Ctrl` + `X` and then press `Y` and then press `Enter`
- Now use this command again to run `rl-swarm`
```bash
dos2unix run_rl_swarm.sh && chmod +x run_rl_swarm.sh && ./run_rl_swarm.sh
```
