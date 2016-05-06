# run as:
#   docker build -f Dockerfile -t wellington-footprint .

# base everything on a recent Ubuntu
FROM debian:latest

# get system packages up to date then install the pyDNase dependencies
RUN apt-get update && apt-get -y upgrade
RUN apt-get -y install python \
         python-pip python-numpy python-scipy python-matplotlib
# this thing needs samtools too
RUN apt-get -y install samtools
RUN apt-get -y install wget
RUN apt-get -y install unzip

# zlib
RUN apt-get install -y zlibc zlib1g zlib1g-dev

# get the uncooperative packages
# note the cascade of commands in the installation. somehow between RUNs the path resets

# cython
RUN wget http://cython.org/release/Cython-0.23.4.tar.gz
RUN tar xfz Cython-0.23.4.tar.gz
RUN cd /Cython-0.23.4 && python setup.py install && cd /

# pysam
RUN wget https://github.com/pysam-developers/pysam/archive/master.zip
RUN unzip master.zip
RUN cd pysam-master && python setup.py install && cd /

# bedops
RUN wget https://github.com/bedops/bedops/releases/download/v2.4.5/bedops_linux_x86_64-v2.4.5.tar.bz2
RUN mkdir bedops && mv bedops_linux_x86_64-v2.4.5.tar.bz2 bedops
RUN cd bedops && tar jxvf bedops_linux_x86_64-v2.4.5.tar.bz2 && cd /
# this placed our bedops binaries in /bedops/bin. remember this for script calling

# cleanup
RUN rm master.zip
RUN rm Cython-0.23.4.tar.gz
RUN rm bedops/bedops_linux_x86_64-v2.4.5.tar.bz2

#scripts come in the same folder as the dockerfile now
RUN mkdir /scripts
ADD . /scripts/

# the scripts include pyDNase
RUN cd scripts/pyDNase-differential && python setup.py install && cd /

MAINTAINER Krzysztof Polanski <k.t.polanski@warwick.ac.uk>

# so this is what is going to run by default when you trigger this, in the virtual machine
# call the wellington wrapper from the other directory while staying in /agave with the files
# note the lack of a default call later. this is a multi-script wrapper
ENTRYPOINT ["bash", "../scripts/wellington_footprint_wrapper.sh"]
