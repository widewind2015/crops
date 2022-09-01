生成容器。
`docker build -t benjaminhu/crops:1 .`

直接生成 BSP 和 SDK。
```
docker run --rm -it --name=crops -v /root/bsp5:/workdir --workdir=/workdir \
  -e MACHINE=apalis-imx8 -e DISTRO=tdx-xwayland -e IMAGE=tdx-reference-minimal-image \
  -e SDK=y benjaminhu/crops:1 startup-tdx.sh`
```

进入容器手动执行 bitbake
```
docker run --rm -it --name=crops -v /root/bsp5:/workdir --workdir=/workdir \
  -e MACHINE=apalis-imx8 benjaminhu/crops:1 startup-tdx.sh
```

首次运行时可能会出现 NXP EULA，按PageDown 到 EULA 底部，然后按 q 退出即可。

`MACHINE` 用于指定所编译 BSP 适用的模块，可使用以下值。运行时必须提供。
`apalis-imx6`, `apalis-imx8`, `apalis-tk1`, `colibri-imx6`, `colibri-imx6ull`, `colibri-imx6ull-emmc`, `colibri-imx7`, `colibri-imx7-emmc`, `colibri-imx8x`, `verdin-imx8mm`, `verdin-imx8mp`

`DISTRO` 发行版本类型，可使用以下值。
`tdx-xwayland`, `tdx-xwayland-rt`, `tdx-xwayland-upstream`, `tdx-xwayland-upstream-rt`

`IMAGE` , Toradex 提高两种参考 image，minimal-image 没有图形框架，在模块上可启动的最小系统。multimedia-image 包含 Qt，Gstreamer, Wayland 软件。
`tdx-reference-minimal-image`, `tdx-reference-multimedia-image`

`SDK` 用于生成 SDK，`SDK=y`
