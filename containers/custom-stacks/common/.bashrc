# git config
git config --global user.email "aaron@aaroncody.com"
git config --global user.name "Aaron Cody"
git config --global push.default simple
git config --global url."git@github.com:".insteadOf "https://github.com/"

# fixup ssh permissions
sudo chmod 700 /home/$NB_USER/.ssh
sudo chmod 644 /home/$NB_USER/.ssh/authorized_keys
sudo chmod 644 /home/$NB_USER/.ssh/config
sudo chmod 600 /home/$NB_USER/.ssh/id_rsa
sudo chmod 644 /home/$NB_USER/.ssh/id_rsa.pub

# PATH
export PATH=/opt/conda/bin:$PATH