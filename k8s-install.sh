#######################################################
#<<prerequisite>>all prerequisite cover by this script#
#													  #
#SWAPOFF                                              #
#Firewalld-OFF                                        #
#SELINUX-DISABLED                                     #
#SERVER-REBOOT                                        #
#HOSTFILE-ENTRY                                       #
#######################################################

sudo apt-get update -y

read -p "Enter Host Name for set server hostname: " host_name
hostnamectl set-hostname $host_name

echo "##########congratulations! your hostname set successfully##########"

read -p "Enter your server IP for hostfile Entry: " server_ip

cat <<EOF >>  /etc/hosts
$server_ip  $host_name
EOF

sed -i '/swap/s/^/#/g' /etc/fstab
swapoff -a

sudo ufw disable

modprobe br_netfilter

##################################################################

echo "##########Remove existing version of docker (if exists)##########"

sudo apt-get remove -y docker docker-engine docker.io containerd runc

echo "##########Install docker on Ubuntu machine##########"

sudo apt-get update -y
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

touch /etc/docker/daemon.json
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF

systemctl daemon-reload

systemctl restart docker && systemctl enable docker

sleep 5

##################################################################

echo "##########Install kubernetes on Ubuntu machine.##########"

sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates curl

sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update -y

sleep 5

sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
systemctl enable kubelet


echo "###Successfully Install kubernetes on Ubuntu machine.###"



