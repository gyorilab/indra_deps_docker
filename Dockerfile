FROM ubuntu:focal

RUN apt-get update && \
    # Install Java
    apt-get install -y openjdk-8-jdk && \
    # jnius-indra requires cython which requires gcc
    apt-get install -y git wget zip unzip bzip2 gcc graphviz graphviz-dev \
        pkg-config python3 python3-pip

# Set default character encoding
# See http://stackoverflow.com/questions/27931668/encoding-problems-when-running-an-app-in-docker-python-java-ruby-with-u/27931669
# See http://stackoverflow.com/questions/39760663/docker-ubuntu-bin-sh-1-locale-gen-not-found
RUN apt-get install -y locales && \
    locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8  #

# Set environment variables
ENV DIRPATH /sw
ENV BNGPATH=$DIRPATH/BioNetGen-2.4.0
ENV PATH="$DIRPATH/miniconda/bin:$PATH"
ENV KAPPAPATH=$DIRPATH/KaSim
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

WORKDIR $DIRPATH

# Set up Miniconda and Python dependencies
RUN cd $DIRPATH && \
    # Install packages that are available via conda directly
    pip install --upgrade pip && \
    pip install cython && \
    # Now install other Python packages via pip
    pip install \
        numpy scipy sympy==1.3 cython nose lxml matplotlib networkx \
        ipython pandas jsonschema coverage python-coveralls boto3 \
        doctest-ignore-unicode sqlalchemy psycopg2-binary reportlab \
        docstring-parser pyjnius==1.1.4 python-libsbml bottle gunicorn \
        openpyxl flask<2.0 flask_restx<0.4 flask_cors obonet \
        jinja2 ndex2==2.0.1 requests stemming nltk<3.6 unidecode future pykqml \
        paths-graph protmapper gilda adeft kappy==4.0.94 pybel==0.15.4 pysb==1.9.1 \
        objectpath rdflib==4.2.2 pygraphviz pybiopax tqdm scikit-learn && \
    pip uninstall -y enum34 && \
    # Download protmapper resources
    python -m protmapper.resources && \
    # Download Adeft models
    python -m adeft.download && \
    # Install BioNetGen
    wget "https://github.com/RuleWorld/bionetgen/releases/download/BioNetGen-2.4.0/BioNetGen-2.4.0-Linux.tgz" \
        -O bionetgen.tar.gz -nv && \
    tar xzf bionetgen.tar.gz

# Add and set up reading systems
# ------------------------------
# SPARSER
ENV SPARSERPATH=$DIRPATH/sparser
ADD r3.core $SPARSERPATH/r3.core
ADD save-semantics.sh $SPARSERPATH/save-semantics.sh
ADD version.txt $SPARSERPATH/version.txt
RUN chmod +x $SPARSERPATH/save-semantics.sh && \
    chmod +x $SPARSERPATH/r3.core

# REACH
# Default character encoding for Java in Docker is not UTF-8, which
# leads to problems with REACH; so we set option
# See https://github.com/docker-library/openjdk/issues/32
ENV JAVA_TOOL_OPTIONS -Dfile.encoding=UTF8
ENV REACHDIR=$DIRPATH/reach
ENV REACHPATH=$REACHDIR/reach-1.6.3-9ed6fe.jar
ENV REACH_VERSION=1.6.3-9ed6fe
ADD reach-1.6.3-9ed6fe.jar $REACHPATH

# MTI
ADD mti_jars.zip $DIRPATH
RUN mkdir $DIRPATH/mti_jars && \
    unzip $DIRPATH/mti_jars.zip -d $DIRPATH/mti_jars/
