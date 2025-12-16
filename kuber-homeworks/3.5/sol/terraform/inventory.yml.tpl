all:
  vars:
    ansible_ssh_extra_args: "-o StrictHostKeyChecking=no"
    ansible_user: ${ssh_user}
    ansible_ssh_private_key_file: ${ssh_private_key_file}
    ansible_python_interpreter: /usr/bin/python3    
  children:
    control:
      hosts:
        localhost:
          ansible_connection: local  
    masters:
      hosts:
%{ for i, ip in masters_internal_ips ~}
        master${i}:
          ansible_host: ${masters_ips[i]}
          internal_ip: ${masters_internal_ips[i]}
          external_ip: ${masters_ips[i]}
%{ endfor ~}
    workers:
      hosts:
%{ for i, ip in workers_internal_ips ~}
        worker${i}:
          ansible_host: ${workers_ips[i]}
          internal_ip: ${workers_internal_ips[i]}
          external_ip: ${workers_ips[i]}
%{ endfor ~}
