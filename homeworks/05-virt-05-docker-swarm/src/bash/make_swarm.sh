#!/bin/bash

# Настройки по умолчанию
NODES=3 # 1 master, 2-3 workers
FOLDER_ID="b1gg3ad99mhgfm5qo1tt"
SUBNET_ID="e9ba5mmqqj76kb3q4m4e"
ZONE="ru-central1-a"
IMAGE_ID="fd8tsuesv8lqis70bmrq" #Debian-12
PLATFORM_ID="standard-v2"
METADATA_FILE="node.yaml"

# Начальное значение последнего октета IP
BASE_IP="10.128.0."
STARTING_OCTET=10

echo "- Making the Docker Swarm cluster on the Yandex cloud...."

if [ $NODES -lt 2 ]; then
    echo "! Error: Nodes < 2. For Swarm cluster need minimum 2 hosts" >&2
    exit 1
fi

for ((i=1; i<=NODES; i++)); do
  # Формируем уникальное имя и IP
  if [ $i -eq 1 ]; then
    INSTANCE_NAME="vm${i}-manager"
  else
    INSTANCE_NAME="vm${i}-worker"
  fi

  IP="${BASE_IP}$((STARTING_OCTET+i))"
  echo "- Create $INSTANCE_NAME ip:$IP"
  
  export INSTANCE_NAME
  # Создаем виртуальную машину
  NAT_IP=$(yc compute instance create $INSTANCE_NAME \
    --zone=$ZONE \
    --folder-id=$FOLDER_ID \
    --network-interface subnet-id=$SUBNET_ID,address=$IP,nat-ip-version=ipv4 \
    --platform-id=$PLATFORM_ID \
    --core-fraction 50 \
    --preemptible \
    --create-boot-disk image-id=$IMAGE_ID,size=10GB,type=network-hdd \
    --memory=2 \
    --cores=2 \
    --metadata-from-file user-data=$METADATA_FILE \
    --format json | jq -r '.network_interfaces[].primary_v4_address.one_to_one_nat.address')

  if [ $? -ne 0 ]; then
    echo "! Error - Create swarm host: $INSTANCE_NAME" >&2
    exit 1
  fi

  # Проверяем, что NAT_IP не пустой
  if [ -z $NAT_IP ]; then
    echo "! Error: Get Host NAT IP: $INSTANCE_NAME" >&2
    exit 1
  fi
  
  # Сохраняем IP в переменную
  declare "HOST${i}_NAT_IP=$NAT_IP"
  
  # Выводим результат
  var_name="HOST${i}_NAT_IP"
  echo "- $INSTANCE_NAME NAT IP: ${!var_name}"
  sleep 5 # Иногда облако тормозит
done



# Ждем доступности по ssh, завершения cloud-init и старта Docker на всех узлах


MAX_RETRIES=12
RETRY_DELAY=5
for ((i=1; i<=NODES; i++)); do
  echo "- Wait ssh connection, cloud-init and docker started on node #$i..."
  LAST_HOST_VAR="HOST${i}_NAT_IP"
  for ((attempt=1; attempt<=MAX_RETRIES; attempt++)); do
    if ssh -i ~/.ssh/netology \
      -o StrictHostKeyChecking=accept-new \
      -o ConnectTimeout=30 \
      -o LogLevel=ERROR \
      $USER@${!LAST_HOST_VAR} \
      "until cloud-init status | grep -q 'done' && \
      systemctl is-active --quiet docker; do 
        sleep 5;
        echo -n '.'; 
      done"; then
      echo -e "\n- All services ready on node #$i"
      break
    fi

    sleep $RETRY_DELAY

    if [ $attempt -eq $MAX_RETRIES ]; then
      echo -e "\n! Error: Failed to connect after $MAX_RETRIES attempts" >&2
      exit 1
    fi
  done
done

# -------------------------- SWARM -------------------------------

# Инициализация менеджера
IP_MAN="${BASE_IP}$((STARTING_OCTET+1))"
echo "- Add manager vm1 ip:$IP_MAN nat_ip:$HOST1_NAT_IP"
W_JOIN_KEY=$(ssh -i ~/.ssh/netology -o StrictHostKeyChecking=accept-new -o ConnectTimeout=10 $USER@$HOST1_NAT_IP "docker swarm init --advertise-addr $IP_MAN &>/dev/null && docker swarm join-token -q worker")

if [ $? -ne 0 ]; then
  echo "! Error - Create swarm manager" >&2
  exit 1
fi

# Инициализация воркеров
for ((i=2; i<=NODES; i++)); do
  INSTANCE_NAME="vm$i-worker"
  HOST_VAR="HOST${i}_NAT_IP"
  IP="${BASE_IP}$((STARTING_OCTET+i))"
  echo "- Add worker $INSTANCE_NAME ip:$IP nat_ip:${!HOST_VAR}"
  ssh -i ~/.ssh/netology -o StrictHostKeyChecking=accept-new -o ConnectTimeout=10 $USER@${!HOST_VAR} \
    "docker swarm join --token $W_JOIN_KEY $IP_MAN:2377"
  
  if [ $? -ne 0 ]; then
    echo "! Error - Create swarm worker#$i" >&2
    exit 1
  fi
done

echo -e "- Make Finish - Docker Swarm Nodes List:\n"

# Результат
ssh -i ~/.ssh/netology -o StrictHostKeyChecking=accept-new -o ConnectTimeout=10 $USER@$HOST1_NAT_IP "docker node ls"