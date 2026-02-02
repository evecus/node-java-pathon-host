#!/bin/bash

# 基础信息配置
UUID=$(cat /proc/sys/kernel/random/uuid)
HY2_PORT=2032
VLESS_PORT=2032
PASSWORD=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 12)

# 1. 生成自签名证书 (用于 Hysteria2)
echo "正在生成自签名证书..."
openssl req -x509 -nodes -newkey rsa:2048 -keyout server.key -out server.crt -subj "/CN=bing.com" -days 3650 2>/dev/null

CERT_PATH=$(pwd)/server.crt
KEY_PATH=$(pwd)/server.key

# 2. 生成 config.json
cat <<EOF > config.json
{
  "log": {
    "level": "info",
    "timestamp": true
  },
  "inbounds": [
    {
      "type": "vless",
      "tag": "vless-in",
      "listen": "::",
      "listen_port": $VLESS_PORT,
      "users": [
        {
          "uuid": "$UUID"
        }
      ]
    },
    {
      "type": "hysteria2",
      "tag": "hy2-in",
      "listen": "::",
      "listen_port": $HY2_PORT,
      "users": [
        {
          "password": "$PASSWORD"
        }
      ],
      "tls": {
        "enabled": true,
        "certificate_path": "$CERT_PATH",
        "key_path": "$KEY_PATH"
      }
    }
  ],
  "outbounds": [
    {
      "type": "direct",
      "tag": "direct"
    }
  ]
}
EOF

echo "--------------------------------------------------"
echo "配置生成成功！"
echo "VLESS UUID: $UUID"
echo "VLESS 端口: $VLESS_PORT (No TLS)"
echo "HY2 密码: $PASSWORD"
echo "HY2 端口: $HY2_PORT"
echo "证书位置: $CERT_PATH"
echo "配置文件: $(pwd)/config.json"
echo "--------------------------------------------------"
