# Openrefine


FROM java:7           *程序需要java环境，所以FROM一个java基础镜像

RUN wget https://github.com/OpenRefine/OpenRefine/releases/download/2.6-rc.2/openrefine-linux-2.6-rc.2.tar.gz     *下载程序打成的tar包
RUN tar zxf openrefine-linux-2.6-rc.2.tar.gz           *解压tar包
RUN cd openrefine-2.6-rc.2/                            *进入程序目录

WORKDIR openrefine-2.6-rc.2/                           *设置工作目录为程序所在的目录      

EXPOSE 3333                                            *映射端口3333，程序默认的端口，可以再调整

CMD ./refine                                           *启动服务


注：由于是容器起来的服务，所以需连接到容器内更改ip和端口号，命令为

./refine -i 0.0.0.0 -p 80

设置完以后生成svc，--port指向80即可。
