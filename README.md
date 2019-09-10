# DigiNance - 
Multiple threaded, lightning fast NVT & Openscap based vulnerability management scanner that can scan host & Application in single click.
# Docker Build
docker build -t digi/nance .
# mkdir /data 
docker run -itd - p 443:443 -v pwd$/data:/var/lib/openvas/mgr --name diginance digi/nance  
