# srs

1. <https://github.com/ossrs/srs/blob/4.0release/trunk/conf/docker.conf>
1. <https://github.com/ossrs/srs/blob/4.0release/trunk/conf/full.conf>

## docker 调用 dvr api 崩溃的问题

挂载配置文件时，不能直接挂载配置文件，必须采取挂载配置文件目录的方式

## 截图无法自动创建路径的问题

通过配置 hls_ts_file 或 dvr_path 间接创建

## dvr_path

### dvr_path

srs dvr 路径可以使用变量，[vhost] [app] [stream] [timestamp] 正常使用即可。
年、月、日、时、分、秒、毫秒则使用以下变量：[2006] [01] [02] [15] [04] [05] [999]。必须这么写，不存在[year]之类的，例如，要想插入年份必须使用[2006]。

### 监控场景

自动录像、按日期存储、按时间分割

```
    dvr {
        enabled on;
        dvr_path ./objs/nginx/html/[app]/[stream]/[2006]/[01]/[02]/[app].[stream].[2006].[01].[02].[15].[04].[05].[999].mp4;
        dvr_apply all;
        dvr_plan segment;
        #seconds
        dvr_duration 60;
    }
```

### 直播场景

自动录像、按会话存储，也可以按时间分割

```
    dvr {
        enabled on;
        dvr_path ./objs/nginx/html/[app]/[stream]/[2006]/[01]/[02]/[app].[stream].[2006].[01].[02].[15].[04].[05].[999].mp4;
        dvr_apply none;
    }
```

### 精确控制

通过 [http api](https://github.com/ossrs/srs/wiki/v4_CN_HTTPApi#raw-dvr) 控制每个流的开始录制和停止录制

```
    dvr {
        enabled on;
        dvr_path ./objs/nginx/html/[app]/[stream]/[2006]/[01]/[02]/[app].[stream].[2006].[01].[02].[15].[04].[05].[999].mp4;
        dvr_apply none;
    }
```


## arm64

参考：<https://github.com/ossrs/srs-docker/tree/aarch64>

Raspberry Pi 安装64位操作系统：<https://downloads.raspberrypi.org/raspios_arm64/images/>

安装 Docker Engine： <https://docs.docker.com/engine/install/debian/>

安装 Docker Compose： <https://github.com/wojiushixiaobai/docker-compose-aarch64>
