#!/bin/bash

if (( $EUID == 0 )); then
	echo " - Please do NOT run as root"
	exit
fi

#Install ROS 2 Humble
echo " - Installing ROS 2 Humble"

echo " - Install Build Tools"

# C++ Build tools
sudo apt install build-essential gdb

# Check if LANG contains UTF-8
if [[ "$LANG" == *"UTF-8"* ]]; then
  echo "UTF-8 charset is already, doing nothing."
else
  read -p "UTF-8 charset is not been set. Choose language (EN/JP): " choice
  case "$choice" in
    EN)
	  sudo apt update
	  sudo apt install -y locales
	  sudo locale-gen en_US en_US.UTF-8
	  sudo update-locale LANG=en_US.UTF-8
	  source /etc/default/locale
	  echo "Set LANG=en_US.UTF-8"
	  ;;
	JP)
	  sudo apt update
	  sudo apt install -y language-pack-ja-base language-pack-ja
	  sudo update-locale LANG=ja_JP.UTF-8
	  source /etc/default/locale
	  echo "Set LANG=ja_JP.UTF-8"
	  ;;
	*)
	  echo "Invalid choice. Exiting."
	  exit 1
	  ;;
  esac
fi

echo " - ROS 2 sources"

# Add ROS2 sources
sudo apt update
sudo apt install -y curl
sudo curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

echo " - Install ROS 2"

# Install ROS 2 (humble)
sudo apt update
sudo apt install -y ros-humble-desktop

# Step envrioment
source /opt/ros/humble/setup.bash

echo " - Install Python ROS 2"

# Argcomplete
sudo apt install -y python3-pip
pip3 install -U argcomplete

# Colcon build tools
sudo apt install -y python3-colcon-common-extensions python3-rosdep2

# Update ROS dep
rosdep update
rosdep fix-permissions

# Add to bashrc
echo " - Register ROS 2 in .bashrc"
grep -qxF 'source /opt/ros/humble/setup.bash' ~/.bashrc || echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
grep -qxF 'source /usr/share/colcon_cd/function/colcon_cd.sh' ~/.bashrc || echo "source /usr/share/colcon_cd/function/colcon_cd.sh" >> ~/.bashrc
grep -qxF 'export _colcon_cd_root=~/ros2_install' ~/.bashrc || echo "export _colcon_cd_root=~/ros2_install" >> ~/.bashrc
source ~/.bashrc

# Install project dependencies
echo " - Python dependencies"
pip3 install catkin_pkg rospkg av image opencv-python djitellopy2 pyyaml
sudo apt install -y python3-tf*

echo " - CPP dependencies"
sudo apt install -y ros-humble-ament-cmake* ros-humble-tf2* ros-humble-rclcpp* ros-humble-rosgraph*

echo " - Rviz and RQT Tools"
sudo apt install -y ros-humble-rviz* ros-humble-rqt*
