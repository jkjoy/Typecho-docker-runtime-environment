# 简介
Typecho在docker中的运行环境 使用lighttpd+php8.3

## 我做了什么

- 增加拓展 `redis` `pdo_mysql` `mysqli` `gd` `intl` `opcache`
- 修改`upload_max_filesize`的值为`100MB`
- 修改`post_max_size`的值为`100MB`
- 增加`Typecho`的固定链接伪静态

## 使用
需要映射网站根目录路径 /app 到宿主机以实现持久化数据

需要映射容器端口 `80`
## 步骤

### 创建目录

赋予本地目录权限

```bash
mkdir data
chown -R 82:82 ./data
```

使用`docker-compose.yaml`

```yaml
services:
  typecho:
    image: jkjoy/typecho-docker
    container_name: typecho
    restart: always
    ports:
      - '9000:80'
    volumes:
      - ./data:/app
```

把`Typecho`源码放入`data`目录下

也可以拉取`mysql`镜像作为网站数据库,也可以使用`sqlite`.

```yaml
services:
  typecho:
    image: jkjoy/typecho-docker
    container_name: typecho
    restart: always
    ports:
      - '9000:80'
    volumes:
      - ./data:/app
    depends_on:
      mysql:
        condition: service_healthy
    networks:
      - typecho_network

  mysql:
    image: mysql:8
    container_name: typechodb
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: typecho #自行修改
      MYSQL_DATABASE: typecho #自行修改
      MYSQL_USER: typecho #自行修改
      MYSQL_PASSWORD: typecho #自行修改
    ports:
      - "3306:3306"
    volumes:
      - ./mysql:/var/lib/mysql
    networks:
      - typecho_network

  phpmyadmin:
    image: phpmyadmin
    container_name: phpmyadmin
    restart: always
    environment:
      PMA_HOST: typechodb
    ports:
      - "8800:80"
    networks:
      - typecho_network

networks:
  typecho_network:
    driver: bridge
```

### 反向代理

nginx可能需要加入
```js
    proxy_set_header X-Forwarded-Proto $scheme; 
```
来传递协议,避免出现协议混淆