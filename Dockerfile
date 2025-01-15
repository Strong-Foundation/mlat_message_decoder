FROM ubuntu:latest

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Update the OS
RUN apt-get update && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get dist-upgrade -y && \
    apt-get clean -y && \
    apt-get autoremove -y && \
    apt-get autoclean -y && \
    apt-get install -f -y

# Install required dependencies
RUN apt-get install bash -y && \
    apt-get install sudo -y && \
    apt-get install wget -y && \
    apt-get install gpg -y && \
    apt-get install apt-transport-https -y && \
    apt-get install curl -y

# Import the Elasticsearch PGP Key
RUN wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | \
    gpg --dearmor -o /usr/share/keyrings/elasticsearch-keyring.gpg

# Install the APT repo sources for Elasticsearch
RUN echo "deb [signed-by=/usr/share/keyrings/elasticsearch-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | \
    tee /etc/apt/sources.list.d/elastic-8.x.list

# Install Elasticsearch
RUN sudo apt-get update && \
    sudo apt-get install elasticsearch -y

# Install Kibana
RUN sudo apt-get update && \
    sudo apt-get install kibana -y

# Create a non-root user and set the correct permissions
RUN useradd -ms /bin/bash kibanauser && \
    echo "kibanauser:yourpassword" | chpasswd && \
    mkdir -p /var/log/kibana /run/kibana && \
    chown -R kibanauser:kibanauser /usr/share/elasticsearch /usr/share/kibana /etc/elasticsearch /etc/kibana /var/log/kibana /run/kibana

# Switch to the new user
USER kibanauser

# Expose the necessary ports
EXPOSE 9200 5601

# Start Elasticsearch and Kibana
CMD ["/bin/bash", "-c", "/usr/share/elasticsearch/bin/elasticsearch & /usr/share/kibana/bin/kibana"]