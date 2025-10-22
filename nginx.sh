#!/bin/bash

# 启动 OpenResty 服务
/opt/openresty-1.13/bin/openresty -p /root/nginx/openresty/work-dir -c /root/nginx/openresty/lua-performance-demo/conf/nginx.conf
#!/bin/bash

# OpenResty 服务管理脚本
OPENRESTY_BIN="/opt/openresty-1.13/bin/openresty"
WORK_DIR="/root/nginx/openresty/work-dir"
CONFIG_FILE="/root/nginx/openresty/lua-performance-demo/conf/nginx.conf"

case "$1" in
    start)
        echo "启动 OpenResty 服务"
        $OPENRESTY_BIN -p $WORK_DIR -c $CONFIG_FILE
        ;;
    stop)
        echo "停止 OpenResty 服务"
        $OPENRESTY_BIN -p $WORK_DIR -c $CONFIG_FILE -s stop
        ;;
    reload)
        echo "重新加载 OpenResty 配置"
        $OPENRESTY_BIN -p $WORK_DIR -c $CONFIG_FILE -s reload
        ;;
    restart)
        echo "重启 OpenResty 服务"
        $OPENRESTY_BIN -p $WORK_DIR -c $CONFIG_FILE -s stop
        sleep 2
        $OPENRESTY_BIN -p $WORK_DIR -c $CONFIG_FILE
        ;;
    *)
        echo "用法: $0 {start|stop|reload|restart}"
        exit 1
        ;;
esac
