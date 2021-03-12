#!/bin/bash

# 開始メッセージ
echo;
printf "\e[33;1m----- NECMP AZ304 Training / Lab01 Setup -----\e[m"
echo;
echo;
echo -n "あなたの <受講者番号> を入力してください = "
read num
echo;
echo "あなたが入力した <受講者番号> は" $num "です"
echo -n "セットアップを開始してよろしいですか？(y/n) = "
read yesno
case "$yesno" in [yY]*) ;; *) echo "終了します" ; exit ;; esac
echo;

# リソースグループの作成
echo "リソースグループ" RG$num "を作成します..."
az group create \
  --name RG$num \
  --location japaneast \
  --output table

# 仮想ネットワークの作成
echo "仮想ネットワーク" VNet$num "を作成します..."
az network vnet create \
  --name VNet$num \
  --resource-group RG$num \
  --address-prefixes 10.0.0.0/16 \
  --subnet-name Frontend \
  --subnet-prefixes 10.0.0.0/24 \
  --output table

# サブネットの追加
echo "サブネット AzureBastionSubnet を作成します..."
az network vnet subnet create \
  --name AzureBastionSubnet \
  --vnet-name VNet$num \
  --resource-group RG$num \
  --address-prefixes "10.0.1.0/24" \
  --output table

# パブリックIPアドレスの作成
echo "パブリックIPアドレス " Pip$num " を作成します..."
az network public-ip create \
  --resource-group RG$num \
  --name Pip$num \
  --sku Standard \
  --location japaneast \
  --output table

# 仮想マシンの作成
echo "仮想マシン" ADDS$num "を作成します..."
az vm create \
    --resource-group RG$num \
    --name ADDS$num \
    --image win2019datacenter \
    --size Standard_B4ms \
    --admin-username admin$num \
    --admin-password 'Pa$$w0rd1234' \
    --vnet-name VNet$num \
    --subnet Frontend \
    --output table

# Azure Bastionの作成
echo "Azure Bastionホスト " Bastion$num " を作成します..."
az network bastion create \
  --name Bastion$num \
  --public-ip-address Pip$num \
  --resource-group RG$num \
  --vnet-name VNet$num \
  --location japaneast \
  --output table

# カスタムスクリプト拡張のインストール
echo "カスタムスクリプト拡張をインストールします..."
az vm extension set \
    --publisher Microsoft.Compute \
    --version 1.8 \
    --name CustomScriptExtension \
    --vm-name ADDS$num \
    --resource-group RG$num \
    --settings '{"fileUris":["https://github.com/necmp/az304/raw/master/cse-lab01.ps1"],"commandToExecute":"powershell.exe -ExecutionPolicy Unrestricted -file cse-lab01.ps1"}' \
    --output table

# 終了メッセージ
echo;
echo "セットアップが完了しました"
echo;