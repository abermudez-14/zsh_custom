#!/bin/bash

set -euo pipefail

# Variables globales
P10K_PATH="$HOME/.config/powerlevel10k/powerlevel10k.zsh"

# Verifica si el script se está ejecutando como root
if [[ "$EUID" -ne 0 ]]; then
  printf "No tienes privilegios de superusuario.\n" >&2
  exit 1
fi

# Función para instalar dependencias
install_dependencies() {
  printf "Instalando dependencias...\n"
  apt update
  apt install -y zsh git lsd bat
}

# Función para cambiar shell predeterminada
change_default_shell() {
  local user_shell
  user_shell=$(which zsh)
  
  if ! chsh -s "$user_shell" "$USER"; then
    printf "Error al cambiar la shell predeterminada para %s.\n" "$USER" >&2
    return 1
  fi
}

# Función para instalar oh-my-zsh
install_oh_my_zsh() {
  printf "Instalando Oh My Zsh...\n"
  if ! sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; then
    printf "Error al instalar Oh My Zsh.\n" >&2
    return 1
  fi
}

# Función para clonar powerlevel10k
clone_powerlevel10k() {
  printf "Clonando Powerlevel10k...\n"
  if ! git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/.config/powerlevel10k"; then
    printf "Error al clonar Powerlevel10k.\n" >&2
    return 1
  fi
}

# Función para configurar .zshrc
configure_zshrc() {
  printf "Configurando .zshrc...\n"
  cat <<EOF > "$HOME/.zshrc"
# Zsh Configuration
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-syntax-highlighting zsh-completions zsh-autosuggestions)

source \$ZSH/oh-my-zsh.sh
source $HOME/.p10k.zsh
EOF
}

# Función para instalar plugins de zsh
install_zsh_plugins() {
  printf "Instalando plugins de Zsh...\n"
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
  git clone https://github.com/zsh-users/zsh-completions.git "$HOME/.oh-my-zsh/custom/plugins/zsh-completions"
  git clone https://github.com/zsh-users/zsh-autosuggestions.git "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
}

# Función para configurar Zsh y Powerlevel10k para root
configure_root() {
  printf "Configurando Zsh y Powerlevel10k para root...\n"
  local root_shell
  root_shell=$(which zsh)

  sudo -u root bash -c "chsh -s $root_shell root"
  sudo -u root bash -c "sh -c '$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)' '' --unattended"
  sudo -u root bash -c "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/.config/powerlevel10k"
  
  # Copia el archivo de configuración de Powerlevel10k para root
  sudo -u root bash -c "cp '$P10K_PATH' /root/.p10k.zsh"
  
  # Configura el archivo .zshrc de root
  cat <<EOF > /root/.zshrc
# Zsh Configuration for root
export ZSH="/root/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-syntax-highlighting zsh-completions zsh-autosuggestions)

source \$ZSH/oh-my-zsh.sh
source /root/.p10k.zsh
EOF
  
  # Instala los plugins para root
  sudo -u root bash -c "git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /root/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
  sudo -u root bash -c "git clone https://github.com/zsh-users/zsh-completions.git /root/.oh-my-zsh/custom/plugins/zsh-completions"
  sudo -u root bash -c "git clone https://github.com/zsh-users/zsh-autosuggestions.git /root/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
}

main() {
  install_dependencies
  change_default_shell
  install_oh_my_zsh
  clone_powerlevel10k
  configure_zshrc
  install_zsh_plugins
  configure_root

  printf "Configuración completada. Por favor, reinicia tu terminal.\n"
}

main "$@"
