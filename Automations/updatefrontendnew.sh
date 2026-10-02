#!/bin/bash
set -e

INSTANCE_ID="i-01e8eae06dad60463"

FILE_TO_FIND="../frontend/.env.docker"

IPV4_ADDRESS=$(aws ec2 describe-instances \
    --instance-ids "$INSTANCE_ID" \
    --query 'Reservations[0].Instances[0].PublicIpAddress' \
    --output text)

if [ -z "$IPV4_ADDRESS" ] || [ "$IPV4_ADDRESS" = "None" ]; then
    echo "ERROR: Could not retrieve EC2 public IP"
    exit 1
fi

echo "EC2 Public IP: $IPV4_ADDRESS"

if [ ! -f "$FILE_TO_FIND" ]; then
    echo "Creating frontend/.env.docker"

    cat > "$FILE_TO_FIND" <<EOF
VITE_API_PATH="http://${IPV4_ADDRESS}:31100"
EOF
else
    echo "Updating frontend/.env.docker"

    if grep -q "^VITE_API_PATH=" "$FILE_TO_FIND"; then
        sed -i "s|^VITE_API_PATH=.*|VITE_API_PATH=\"http://${IPV4_ADDRESS}:31100\"|" "$FILE_TO_FIND"
    else
        echo "VITE_API_PATH=\"http://${IPV4_ADDRESS}:31100\"" >> "$FILE_TO_FIND"
    fi
fi

echo "===== frontend/.env.docker ====="
cat "$FILE_TO_FIND"
