#!/usr/bin/env bash
# Первый запуск сервера salary-bot: ключ доступа к приватному репозиторию (deploy key, только чтение),
# клонирование в /opt/salary-bot и настройка (deploy/setup_vm.sh из приватного репозитория).
set -euo pipefail
REPO=git@github.com:superbatman191-commits/salary-bot.git
KEY="$HOME/.ssh/salary_bot_deploy"
mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
[ -f "$KEY" ] || ssh-keygen -q -t ed25519 -N "" -C "salary-bot-server" -f "$KEY"
grep -q "salary_bot_deploy" "$HOME/.ssh/config" 2>/dev/null || printf 'Host github.com\n  IdentityFile %s\n  IdentitiesOnly yes\n' "$KEY" >> "$HOME/.ssh/config"
ssh-keyscan -t ed25519 github.com >> "$HOME/.ssh/known_hosts" 2>/dev/null
if ! git ls-remote -q "$REPO" >/dev/null 2>&1; then
  echo "=== КЛЮЧ ДЛЯ GITHUB (Deploy key, без права записи) ==="
  cat "$KEY.pub"
  echo "=== добавь его: github.com/superbatman191-commits/salary-bot/settings/keys/new ==="
  for i in $(seq 1 120); do
    git ls-remote -q "$REPO" >/dev/null 2>&1 && break
    sleep 10
  done
fi
git ls-remote -q "$REPO" >/dev/null 2>&1 || { echo "Ключ так и не добавлен. Запусти этот скрипт ещё раз."; exit 1; }
echo "доступ к GitHub есть"
sudo mkdir -p /opt/salary-bot && sudo chown "$(id -un)": /opt/salary-bot
[ -d /opt/salary-bot/.git ] || git clone -q "$REPO" /opt/salary-bot
bash /opt/salary-bot/deploy/setup_vm.sh
