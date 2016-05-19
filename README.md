# Openrefine Dockerfile


    FROM java:7           

程序需要java环境，所以FROM一个java基础镜像  

    RUN wget https://github.com/OpenRefine/OpenRefine/releases/download/2.6-rc.2/openrefine-linux-2.6-rc.2.tar.gz

下载程序打成的tar包  

    RUN tar zxf openrefine-linux-2.6-rc.2.tar.gz

解压tar包  

    RUN cd openrefine-2.6-rc.2/

进入程序目录  

    WORKDIR openrefine-2.6-rc.2/

设置工作目录为程序所在的目录        

    EXPOSE 3333 

映射端口3333，程序默认的端口，可以再调整  

    CMD ./refine

启动服务




#Openrefine部署
1.  首先将我们需要的代码`oc new-build`下来
  


        [songzx@openshift-container-deploy2 ~]$ oc new-build https://github.com/szx0512/szx.git  
    
  等待build完成
  


2.  build完成之后 ，我们使用`oc run`命令指定一个名字，并指定镜像给他跑起来



    [songzx@openshift-container-deploy2 ~]$ oc run openrefine --image=172.30.38.161:5000/songzx/openrefine

    deploymentconfig "openrefine" created
    [songzx@openshift-container-deploy2 ~]$ oc get po
    NAME                     READY     STATUS              RESTARTS   AGE
    openrefine-1-1pel0       0/1       ContainerCreating   0          2s
    openrefine-1-deploy      1/1       Running             0          6s

我们等他部署完成  

3.  部署完成后，我们使用`oc get pod` 查看一下pod运行状况


    songzx@openshift-container-deploy2 ~]$ oc get po
    NAME                     READY     STATUS      RESTARTS   AGE
    openrefine-1-1pel0       1/1       Running     0          1m
  



我们看到openrefine正在运行  
  
4.  因openrefine使用的是默认配置，所以我们需要去到容器里看一下它的配置是什么，该怎样去修改


    [songzx@openshift-container-deploy2 ~]$ oc rsh openrefine-1-1pel0
    # 
    # 

我们通过`oc rsh` 命令连进了容器，容器中有个启动脚本需要我们手动启动，脚本名字是 `refine`，我们可以看一下


    # ls
    LICENSE.txt  README.txt  licenses  refine  refine.ini  server  webapp
  
服务中默认的配置的ip是127.0.0.1  默认的端口号是3333   ，  因为在容器中并不能使用127.0.0.1去对外连接，故改为0.0.0.0，端口号尽量使用我们的习惯，所以我就暂且把它改为80，方便我们访问，命令如下

     ./refine -i 0.0.0.0 -p 80
 
 之后出现如下信息

    Starting OpenRefine at 'http://0.0.0.0:80/'
    03:14:16.780 [            refine_server] Starting Server bound to '0.0.0.0:80' (0ms)
    03:14:16.781 [            refine_server] refine.memory size: 1400M JVM Max heap: 1304952832 (1ms)
    03:14:16.789 [            refine_server] Initializing context: '/' from '/openrefine-2.6-rc.2/webapp' (8ms)

我们可以看到现在openrefine服务正在启动，这里等待时间比较长，因为它需要更改ip和端口号并且重新部署里面的项目，所以我们耐心等待，一般是十到十五分钟左右。


我们看到已经启动完成：

    Starting OpenRefine at 'http://0.0.0.0:80/'


    03:14:16.780 [            refine_server] Starting Server bound to '0.0.0.0:80' (0ms)
    03:14:16.781 [            refine_server] refine.memory size: 1400M JVM Max heap: 1304952832 (1ms)
    03:14:16.789 [            refine_server] Initializing context: '/' from '/openrefine-2.6-rc.2/webapp' (8ms)
    03:14:52.109 [                   refine] Starting OpenRefine 2.6-rc.2 [TRUNK]... (35320ms)
    03:14:53.407 [                   refine] Sorry, some error prevented us from launching the browser for you.

    Point your browser to http://0.0.0.0:80/ to start using Refine. (1298ms)

这个时候我们看到会有报错信息，这个不影响我们正常访问使用，因为这个服务配置文件中有一个启动后需要打开浏览器，这里显示找不到浏览器，所以我们不用在意这个报错，只要外部可以正常使用正常显示就可以了，接下来我们退出容器，去给服务配置route  

  
5.  我们先生成一个svc，并指定端口为80


    [songzx@openshift-container-deploy2 ~]$ oc expose dc openrefine --port=80
    service "openrefine" exposed
  

6.  接下来就是我们给openrefine服务做一个route，让他可以外网访问


    [songzx@openshift-container-deploy2 ~]$ oc expose svc openrefine 
    route "openrefine" exposed  
  

7.  我们通过查看服务的域名去进行访问测试，这样，openrefine就搭建完成了。


    [songzx@openshift-container-deploy2 ~]$ oc get route
    NAME         HOST/PORT                         PATH      SERVICE      TERMINATION   LABELS
    openrefine   openrefine-songzx.app.dataos.io             openrefine                 run=openrefine
  
