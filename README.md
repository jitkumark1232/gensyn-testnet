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

![How to Add SSH Key](https://github.com/user-attachments/assets/c5a402df-db90-43ca-ad99-500dcf28335e)

---

## ⚙️ Server Setup (Clore Dashboard)

1. Select `Ubuntu Jupyter` as the image.
2. **Delete** extra HTTP ports.
3. **Add** HTTP port: `3000`.
4. Click **Create** to deploy your node.

![Server Setup Screenshot](https://github.com/user-attachments/assets/eb8089fc-923a-4157-8143-450afaf4c2dd)

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

1. **Thank you Legends to both the Zun & FragIfty01
```bash
These repo's helped me a lot while doing gensyn Node setup
https://github.com/FragIfty01/Gensyn-via-Clore-ai/
https://github.com/zunxbt/gensyn-testnet
```


## 📥 Installation

1. **Install `sudo`**
```bash
apt update && apt install -y sudo
```
2. **Install other dependencies**
```bash
sudo apt update && sudo apt install -y python3 python3-venv python3-pip curl wget screen git lsof nano unzip
```
```bash
pip install hivemind colorlog
```
3. **Install Node.js and npm**  
```bash
curl -sSL https://raw.githubusercontent.com/zunxbt/installation/main/node.sh | bash
```
4. **Create a `screen` session**
```bash
screen -S gensyn
```
## ⚠️Important⚠️ (SKIP) This step, If this your first time of setting up Gensyn Node
Fist backup Your gensyn Node swarm.pem file
Here's how u can do it in termius 

**1st Method**
watch this youtube tutorial.
https://youtu.be/lBEjrUGKUN4

**2nd Method**
**if you want to importing old `swarm.pem` file then must use Gdrive url like the below example**

GDRIVE Always gives the sharing link instead of link that support direct downloading and gensyn script asks for direct downloading link so you must set it up properly
here's how you can do it.
follow this structure:
- `Sharing Link:https://drive.google.com/file/d/14LOT0Jb4mQEw-igPQpCr55Gaeq6ErU_2/view?usp=sharing`

Example of File ID- `14LOT0Jb4mQEw-igPQpCr55Gaeq6ErU_2` and use it and ADD this id after `/uc?id=14LOT0Jb4mQEw-igPQpCr55Gaeq6ErU_2`
Then the url should be like this 👇👇

- Direct Download Link:
`https://drive.google.com/uc?id=14LOT0Jb4mQEw-igPQpCr55Gaeq6ErU_2`

**3rd Method**
You can also backup Your files via running commands and for it move to the below Step of " ## 🔄️ Back up `swarm.pem` "

## Sign up here your NGROK Account 
https://dashboard.ngrok.com/get-started/ and go to `Your auth` Option and save it then enter this key when asked in the `code space.`

## 5. **Run the swarm**

```bash
sudo apt update && sudo apt install dos2unix -y
cd $HOME && rm -rf gensyn-testnet && git clone https://github.com/jitkumark1232/gensyn-testnet.git && dos2unix gensyn-testnet/gensyn.sh && chmod +x gensyn-testnet/gensyn.sh && ./gensyn-testnet/gensyn.sh
&& cd /root/rl-swarm/hivemind_exp/gsm8k/stage2_rewards.py && dos2unix /root/rl-swarm/hivemind_exp/gsm8k/stage2_rewards.py
```
```bash
cd $HOME
source "$HOME/rl-swarm/.venv/bin/activate"
```

```bash
cd /root/rl-swarm/ && dos2unix run_rl_swarm.sh && chmod +x run_rl_swarm.sh && ./run_rl_swarm.sh
```

- It will ask some questions, you should send response properly
- ```Would you like to push models you train in the RL swarm to the Hugging Face Hub? [y/N]``` : Write `N`
- When you will see interface like this, you can detach from this screen session

![Screenshot 2025-04-01 061641](https://github.com/user-attachments/assets/b5ed9645-16a2-4911-8a73-97e21fdde274)

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
