#!/bin/bash

sudo systemctl stop modep-mod-ui modep-mod-host jack

# 権限修正
sudo chown -R "$USER:$USER" build
sudo chown -R "$USER:$USER" subprojects

# Mesonビルド
meson setup --reconfigure build
meson subprojects update
meson build --buildtype=release --prefix=/usr --libdir=lib
meson compile -C build -v
sudo meson install -C build

# LV2バンドルをmodep用ディレクトリにコピー
cp -r /usr/lib/lv2/nrepellent_kai.lv2/ /var/modep/lv2

sudo systemctl start jack modep-mod-host modep-mod-ui

echo "ビルドとコピーが完了しました。"
