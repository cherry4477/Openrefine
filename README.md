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
.  首先将我们需要的代码`oc new-build`下来


        [songzx@openshift-container-deploy2 ~]$ oc new-build https://github.com/szx0512/szx.git  
    
  等待build完成
  

.   build完成之后 ，我们使用`oc run`命令指定一个名字，并指定镜像给他跑起来


        [songzx@openshift-container-deploy2 ~]$ oc run openrefine --image=172.30.38.161:5000/songzx/openrefine

        deploymentconfig "openrefine" created
        [songzx@openshift-container-deploy2 ~]$ oc get po
        NAME                     READY     STATUS              RESTARTS   AGE
        openrefine-1-1pel0       0/1       ContainerCreating   0          2s
        openrefine-1-deploy      1/1       Running             0          6s

我们等他部署完成  

.  部署完成后，我们使用`oc get pod` 查看一下pod运行状况


        songzx@openshift-container-deploy2 ~]$ oc get po
        NAME                     READY     STATUS      RESTARTS   AGE
        openrefine-1-1pel0       1/1       Running     0          1m
  



我们看到openrefine正在运行  
  
.  因openrefine使用的是默认配置，所以我们按照自己的需要去修改，dockerfile里面写的是默认配置，直接使用即可，我们可以进入容器看一下里面的项目，方便之后出错的排错工作


        [songzx@openshift-container-deploy2 ~]$ oc rsh openrefine-1-1pel0
        # 
        # 

我们通过`oc rsh` 命令连进了容器，容器中有个启动脚本，我们可以通过它来配置，脚本名字是 `refine`，


        # ls
        LICENSE.txt  README.txt  licenses  refine  refine.ini  server  webapp
  
  所有的配置工作已经全都集成在了dockerfile里面，如果需要更改用的ip和端口，可以根据refine命令去完成，
`./refine help`   可以查看所有帮助信息

了解完启动脚本之后我们可以通过`oc logs -f openrefine`命令查看服务的启动日志


我们看到已经启动完成：

        Starting OpenRefine at 'http://0.0.0.0:3333/'


        03:14:16.780 [            refine_server] Starting Server bound to '0.0.0.0:3333' (0ms)
        03:14:16.781 [            refine_server] refine.memory size: 1400M JVM Max heap: 1304952832 (1ms)
        03:14:16.789 [            refine_server] Initializing context: '/' from '/openrefine-2.6-rc.2/webapp' (8ms)
        03:14:52.109 [                   refine] Starting OpenRefine 2.6-rc.2 [TRUNK]... (35320ms)
        03:14:53.407 [                   refine] Sorry, some error prevented us from launching the browser for you.

        Point your browser to http://0.0.0.0:3333/ to start using Refine. (1298ms)

这个时候我们看到会有报错信息，这个不影响我们正常访问使用，因为这个服务配置文件中有一个启动后需要打开浏览器，这里显示找不到浏览器，所以我们不用在意这个报错，只要外部可以正常使用正常显示就可以了，接下来我们退出容器，去给服务配置route


.  我们先生成一个svc，并指定端口为3333


        [songzx@openshift-container-deploy2 ~]$ oc expose dc openrefine --port=3333
        service "openrefine" exposed
  

.  接下来就是我们给openrefine服务做一个route，让他可以外网访问



        [songzx@openshift-container-deploy2 ~]$ oc expose svc openrefine 
        route "openrefine" exposed

 

.  我们通过查看服务的域名去进行访问测试，这样，openrefine就搭建完成了。




        [songzx@openshift-container-deploy2 ~]$ oc get route
        NAME         HOST/PORT                         PATH      SERVICE      TERMINATION   LABELS
        openrefine   openrefine-songzx.app.dataos.io             openrefine                 run=openrefine
