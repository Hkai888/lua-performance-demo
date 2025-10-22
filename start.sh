#!/bin/bash

# 启动 OpenResty 服务
/opt/openresty-1.13/bin/openresty -p /root/nginx/openresty/work-dir -c /root/nginx/openresty/lua-performance-demo/conf/nginx.conf
