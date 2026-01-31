#!/bin/bash
# ============================================
# Hercules Emulator Entrypoint Script
# ============================================
set -e

# Wait for database to be ready
echo "Waiting for database at ${DB_HOST}:${DB_PORT}..."
while ! nc -z "${DB_HOST}" "${DB_PORT}"; do
    echo "Database not ready, waiting..."
    sleep 2
done
echo "Database is ready!"

# Generate import configs with environment variables
CONFIG_DIR="/hercules/conf/import"

# Create sql_connection.conf
cat > "${CONFIG_DIR}/sql_connection.conf" << EOF
sql_connection: {
    db_hostname: "${DB_HOST}"
    db_port: ${DB_PORT}
    db_username: "${DB_USER}"
    db_password: "${DB_PASS}"
    db_database: "${DB_NAME}"
}
EOF

# Create inter-server.conf
cat > "${CONFIG_DIR}/inter-server.conf" << EOF
inter_configuration: {
    log: {
        sql_connection: {
            db_hostname: "${DB_HOST}"
            db_port: ${DB_PORT}
            db_username: "${DB_USER}"
            db_password: "${DB_PASS}"
            db_database: "${DB_NAME}_log"
        }
    }
}
EOF

# Create char-server.conf with public IP
cat > "${CONFIG_DIR}/char-server.conf" << EOF
char_configuration: {
    inter: {
        userid: "s1"
        passwd: "p1"
    }
    char_server: {
        server_name: "${SERVER_NAME}"
        wisp_server_name: "${WISP_NAME}"
    }
}
EOF

# Create map-server.conf with public IP
cat > "${CONFIG_DIR}/map-server.conf" << EOF
map_configuration: {
    inter: {
        userid: "s1"
        passwd: "p1"
    }
}
EOF

# Create login-server.conf
cat > "${CONFIG_DIR}/login-server.conf" << EOF
login_configuration: {
    inter: {
        use_dnshost: false
        dnshost: ""
    }
}
EOF

# Set ownership
chown -R hercules:hercules /hercules

echo "Starting Hercules servers..."
echo "Server Name: ${SERVER_NAME}"
echo "Public IP: ${PUBLIC_IP}"

# Start servers
cd /hercules

# Start login server
echo "Starting login-server..."
gosu hercules ./login-server &

sleep 2

# Start char server
echo "Starting char-server..."
gosu hercules ./char-server &

sleep 2

# Start map server
echo "Starting map-server..."
gosu hercules ./map-server &

# Wait for any process to exit
wait -n

# Exit with status of process that exited first
exit $?
