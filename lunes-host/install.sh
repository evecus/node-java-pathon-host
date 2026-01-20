#!/usr/bin/env sh

DOMAIN="${DOMAIN:-node68.lunes.host}"
PORT="${PORT:-10008}"
HY2_PASSWORD="${HY2_PASSWORD:-9899f880-32f9-44a3-b0ee-271819cdb570}"

curl -sSL -o app.js https://raw.githubusercontent.com/evecus/node-java-pathon-host/refs/heads/main/lunes-host/app.js
curl -sSL -o package.json https://raw.githubusercontent.com/evecus/node-java-pathon-host/refs/heads/main/lunes-host/package.json

mkdir -p /home/container/h2
cd /home/container/h2
curl -sSL -o h2 https://github.com/apernet/hysteria/releases/download/app%2Fv2.7.0/hysteria-linux-amd64
curl -sSL -o config.yaml https://raw.githubusercontent.com/evecus/node-java-pathon-host/refs/heads/main/lunes-host/hysteria-config.yaml
openssl req -x509 -newkey rsa:2048 -days 3650 -nodes -keyout key.pem -out cert.pem -subj "/CN=$DOMAIN"
chmod +x h2
sed -i "s/10008/$PORT/g" config.yaml
sed -i "s/HY2_PASSWORD/$HY2_PASSWORD/g" config.yaml
encodedHy2Pwd=$(node -e "console.log(encodeURIComponent(process.argv[1]))" "$HY2_PASSWORD")
hy2Url="hysteria2://$encodedHy2Pwd@$DOMAIN:$PORT?insecure=1#nodejs-hy2"
echo $hy2Url >> /home/container/node.txt

echo "============================================================"
echo "🚀 HY2 Node Info"
echo "------------------------------------------------------------"
echo "$hy2Url"
echo "============================================================"
