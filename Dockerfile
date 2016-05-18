FROM java：7

RUN wget https://github.com/OpenRefine/OpenRefine/releases/download/2.6-rc.2/openrefine-linux-2.6-rc.2.tar.gz
RUN tar zxf openrefine-linux-2.6-rc.2.tar.gz
RUN cd openrefine-2.6-rc.2/

WORKDIR openrefine-2.6-rc.2/
EXPOSE 3333

CMD ./refine
