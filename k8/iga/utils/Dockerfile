FROM openjdk:11.0-jre-slim

RUN mkdir /app
COPY . /app
WORKDIR /app

RUN apt update
RUN apt install -y python3 python3-pip
RUN pip3 install jwcrypto==0.9.1 

RUN apt update && \
      apt install -y curl && \
      curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl && \
      chmod +x ./kubectl && \
      mv ./kubectl /usr/local/bin/kubectl
      
CMD /app/create-secrets.sh
