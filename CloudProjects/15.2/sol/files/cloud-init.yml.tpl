#cloud-config
write_files:
  - path: /var/www/html/index.html
    permissions: '0644'
    content: |
      <!DOCTYPE html>
      <html>
      <head>
        <title>Netology hw15</title>
      </head>
      <body>
        <h1>"Hello from ${host_name} - part of ${ig_name} Instance Group"</h1>
        <img src="${image_url}"/>
      </body>
      </html>

runcmd:
  - systemctl enable nginx
  - systemctl restart nginx
