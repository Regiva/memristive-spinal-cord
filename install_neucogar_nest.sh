#!/bin/sh

# This script will install The NeuCogAr NEST 2.12.0

printf "Hello! This script will install NeuCogAr NEST Simulator 2.12.0 with Python (2 or 3)"
printf "\nWhich directory will be user to install NeuCogAr NEST? (default /opt/neucogar-nest):"
NEST_VERSION='2.12.0'
read NEST_PATH
if test "$NEST_PATH" = "" ; then
  NEST_PATH="/opt/neucogar-nest"
fi
printf "NEST will be installed in $NEST_PATH"
printf "\nWhich Python version (2 or 3) will be used? (default 3):"
read PYTHON_VERSION
CORRECT=false
while ! ${CORRECT} ; do
  if test "$PYTHON_VERSION" = "2" || test "$PYTHON_VERSION" = "3" ; then
    CORRECT=true
  elif test "$PYTHON_VERSION" = "" ; then
    PYTHON_VERSION="3"
    CORRECT=true
  else
    printf "\nPlease, choose 2, or 3, or just press ENTER to use Python 3"
  fi
done
printf "Python $PYTHON_VERSION has been chosen"

if test "`which python$PYTHON_VERSION`" = "" ; then
  printf "\nPython $PYTHON_VERSION is not found and will be installed"
  read WAITING
  if test "$PYTHON_VERSION" = "2" ; then
    sudo apt-get install python-minimal --assume-yes
  elif test "$PYTHON_VERSION" = "3" ; then
    sudo apt-get install python3-minimal --assume-yes
  fi
fi
PYTHON_EXECUTABLE=`which python${PYTHON_VERSION}`
printf "\nPython $PYTHON_VERSION executable: $PYTHON_EXECUTABLE"
printf "\nPress ENTER to install NeuCogAr NEST ${NEST_VERSION} with Python$PYTHON_VERSION into $NEST_PATH"
read WAITING

sudo apt-get update

# installing python and python libs
sudo apt-get install python-all-dev python-numpy python-scipy python-matplotlib python-nose ipython cython --assume-yes
# installing cmake
sudo apt-get install cmake build-essential autoconf automake libncurses5-dev --assume-yes
# installing GNU Scientific Lib
sudo apt-get install gsl-bin libgsl2 libgsl0-dev libgsl0-dbg --assume-yes
# installing MPI
sudo apt-get install openmpi-bin libopenmpi-dev --assume-yes
# installing LTDL
sudo apt-get install libtool libltdl7-dev --assume-yes
# installing Doxygen
sudo apt-get install doxygen --assume-yes
# installing pip and others with pip
if test "$PYTHON_VERSION" = "2" ; then
  sudo apt-get install python-pip --assume-yes
  sudo -H pip install --upgrade pip
  sudo -H pip install scipy nose matplotlib cython numpy
elif test "$PYTHON_VERSION" = "3" ; then
  sudo apt-get install python3-pip --assume-yes
  sudo -H pip3 install --upgrade pip
  sudo -H pip3 install scipy nose matplotlib cython numpy
fi
# installing Readline
sudo apt-get install libreadline6 libreadline6-dev --assume-yes
# installing pkg-config
sudo apt-get install pkg-config cmake-data --assume-yes
# installing tkinter module
sudo apt-get install python3-tk --assume-yes
sudo apt-get install unzip --assume-yes

sudo apt-get autoremove --assume-yes

NEST_NAME="nest-${NEST_VERSION}"
TMP_FOLDER=/tmp
sudo mkdir -p ${TMP_FOLDER}
sudo wget -c https://github.com/research-team/neucogar-nest/archive/master.zip -O ${TMP_FOLDER}/"$NEST_NAME".zip
sudo mkdir -p ${NEST_PATH}
sudo chown -R "$USER" ${NEST_PATH}
mkdir -p ${NEST_PATH}/src
mkdir -p ${NEST_PATH}/build/${NEST_NAME}
unzip -o ${TMP_FOLDER}/"$NEST_NAME".zip -d ${NEST_PATH}/src
cd ${NEST_PATH}/build/${NEST_NAME}
mv -f ${NEST_PATH}/src/`ls ${NEST_PATH}/src` ${NEST_PATH}/src/${NEST_NAME}
cmake -DCMAKE_INSTALL_PREFIX:PATH=${NEST_PATH}/${NEST_NAME} ${NEST_PATH}/src/${NEST_NAME} -Dwith-mpi=ON -Dwith-python=${PYTHON_VERSION} -DPYTHON_EXECUTABLE=$PYTHON_EXECUTABLE # -DPYTHON_LIBRARY=/usr/lib/python3.5
make --jobs `nproc`
make install
# make installcheck
# NEST_VARS=${NEST_PATH}/${NEST_NAME}/bin/nest_vars.sh
# ${NEST_VARS}
# bash ${NEST_VARS}
# if ! grep -q -F "source '$NEST_VARS'" ~/.profile ; then
#   echo '# NEST env\n[ -f '${NEST_VARS}' ] && source '${NEST_VARS} >> ~/.profile
# fi
cat ${NEST_PATH}/${NEST_NAME}/bin/nest_vars.sh >> ~/.bashrc
sudo rm -rf ${TMP_FOLDER}/"$NEST_NAME".zip


# hh-moto-5ht model installation
sudo apt-get install openjdk-8-jdk --assume-yes
JAVA_HOME=/usr/lib/jvm/`ls /usr/lib/jvm/ | grep java-8-openjdk`

# maven installation
sudo mkdir /opt/maven
cd /opt/maven
sudo wget http://mirror.linux-ia64.org/apache/maven/maven-3/3.5.3/binaries/apache-maven-3.5.3-bin.tar.gz
sudo chown -R ${USER} /opt/maven
tar xzvf apache-maven-3.5.3-bin.tar.gz
# PATH=/opt/maven/apache-maven-3.5.2/bin/:${PATH}

# mpmath installation
sudo mkdir /opt/mpmath && cd /opt/mpmath
sudo chown -R ${USER} .
wget https://pypi.python.org/packages/7a/05/b3d1472885d8dc0606936ea5da0ccb1b4785682e78ab15e34ada24aea8d5/mpmath-1.0.0.tar.gz
tar xzvf mpmath-1.0.0.tar.gz
cd mpmath-1.0.0
sudo python setup.py install

# sympy installation
sudo apt-get install git --assume-yes
cd /opt/
sudo git clone git://github.com/sympy/sympy.git
sudo chown -R ${USER} /opt/sympy
cd /opt/sympy
git pull origin master
sudo python setup.py install

# nestml installation
cd /opt/
sudo git clone https://github.com/nest/nestml.git
sudo chown -R ${USER} /opt/nestml
cd /opt/nestml
sudo /opt/maven/apache-maven-3.5.3/bin/mvn clean install

# hh-moto-5ht installation
cd /opt/
sudo git clone https://github.com/research-team/hh-moto-5ht.git
sudo chown -R ${USER} /opt/hh-moto-5ht
cd hh-moto-5ht
java -jar /opt/nestml/target/nestml.jar research_team_models --target build
cd build
cmake -Dwith-nest=${NEST_PATH}/${NEST_NAME}/bin/nest-config .
make --jobs `nproc` all
make install

# removing temp
sudo rm -rf /opt/maven/ /opt/hh-moto-5ht/ /opt/sympy/ /opt/nestml/ /opt/mpmath/
