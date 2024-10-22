#!/bin/bash

# Verifica si el script se está ejecutando como root
if [ "$EUID" -ne 0 ]; then
  echo "No tienes privilegios de superusuario."
  exit 1
fi

# Instala las dependencias necesarias
apt update
apt install -y zsh git

# Cambia la shell predeterminada a zsh
chsh -s $(which zsh) $USER

# Instala oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Clona powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $HOME/.config/powerlevel10k


# Configura .zshrc
cat <<EOF > $HOME/.zshrc
# Zsh Configuration
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-syntax-highlighting zsh-completions zsh-autosuggestions)

source \$ZSH/oh-my-zsh.sh
source $HOME/.p10k.zsh
EOF

# Instala plugins
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-completions.git $HOME/.oh-my-zsh/custom/plugins/zsh-completions
git clone https://github.com/zsh-users/zsh-autosuggestions.git $HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions

# Instala lsd y batcat
apt install -y lsd bat

# Configura para el usuario root
sudo -u root bash -c "chsh -s $(which zsh) root"
sudo -u root bash -c "sh -c '$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)' '' --unattended"
sudo -u root bash -c "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/.config/powerlevel10k"

# Copia el archivo p10k.zsh al directorio de root
sudo -u root bash -c "cp '$p10k_path' /root/.p10k.zsh"

# Configura .zshrc para root
cat <<EOF > /root/.zshrc
# Zsh Configuration for root
export ZSH="/root/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-syntax-highlighting zsh-completions zsh-autosuggestions)

source \$ZSH/oh-my-zsh.sh
source /root/.p10k.zsh
EOF

# Instala plugins para root
sudo -u root bash -c "git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /root/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
sudo -u root bash -c "git clone https://github.com/zsh-users/zsh-completions.git /root/.oh-my-zsh/custom/plugins/zsh-completions"
sudo -u root bash -c "git clone https://github.com/zsh-users/zsh-autosuggestions.git /root/.oh-my-zsh/custom/plugins/zsh-autosuggestions"

echo "Configuración completada. Por favor, reinicia tu terminal."
