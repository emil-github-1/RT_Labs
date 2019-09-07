FROM ubuntu:16.04

RUN apt-get update && apt-get install -y openssh-server
RUN mkdir /var/run/sshd
RUN echo 'root:pass1234' | chpasswd
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

RUN echo "#!/bin/bash\n" \
    "html=\"/var/www/html/index.nginx-debian.html\"\n" \
    "echo \"\" > \$html\n" \
    "echo \"<html><head></head><body><h1><font color=\"blue\">Number of CPU cores<font></h1><font color=\"black\">\" >> \$html\n" \
    "cat /proc/cpuinfo | grep \"cpu cores\" >> \$html\n" \
    "echo \"<font><h1><font color=\"blue\">Memory Usage<font></h1><font color=\"black\">\" >> \$html\n" \
    "echo \"RAM `free -m | awk '/Mem:/ { printf("%3.1f%%", $3/$2*100) }'`\" >> \$html\n" \
    "echo \"<font><h1><font color=\"blue\">Disk Usage<font></h1><font color=\"black\">\" >> \$html\n" \
    "echo \"HDD `df -h / | awk '/\// {print $(NF-1)}'`\" >> \$html\n" \
    "echo \"<font></body></html>\" >> \$html\n" > /root/remote.sh

RUN chmod +x /root/remote.sh

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
