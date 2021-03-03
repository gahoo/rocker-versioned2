#/bin/bash
set -e

export CUDA_VERSION="10.2"
export R_VERSION="4.0.3"
#export OS="l4t_r32.4.4"
export OS="ubuntu18.04"

rm Dockerfile
ln -s "dockerfiles/Dockerfile_r-ver_${R_VERSION}-${OS}" Dockerfile
docker build -t "rocker/r-ver:${R_VERSION}-${OS}" .

rm Dockerfile
ln -s "dockerfiles/Dockerfile_r-ver_${R_VERSION}-${OS}-cuda${CUDA_VERSION}" Dockerfile
nvidia-docker build -t "rocker/r-ver:${R_VERSION}-${OS}-cuda${CUDA_VERSION}" .


# use nvidia runtime to build cuda support on second layer
sudo sed '/"registry-mirrors"/i "default-runtime": "nvidia",' -i /etc/docker/daemon.json
sudo systemctl restart docker
rm Dockerfile
ln -s dockerfiles/Dockerfile_r-ver_${R_VERSION}-${OS}-cuda${CUDA_VERSION}-arrow Dockerfile
nvidia-docker build -t "rocker/r-ver:${R_VERSION}-${OS}-cuda${CUDA_VERSION}-arrow" .
sudo sed '/default-runtime/d' -i /etc/docker/daemon.json
sudo systemctl restart docker

rm Dockerfile
ln -s dockerfiles/Dockerfile_r-ver_${R_VERSION}-${OS}-cuda${CUDA_VERSION}-rstudio Dockerfile
docker build -t "rocker/rstudio:${R_VERSION}-${OS}-cuda${CUDA_VERSION}" .

rm Dockerfile
ln -s dockerfiles/Dockerfile_r-ver_${R_VERSION}-${OS}-cuda${CUDA_VERSION}-ml Dockerfile
docker build -t "rocker/ml:${R_VERSION}-${OS}-cuda${CUDA_VERSION}" .

rm Dockerfile
ln -s "dockerfiles/Dockerfile_r-ver_${R_VERSION}-${OS}-cuda${CUDA_VERSION}-ml-verse" Dockerfile
docker build --no-cache -t "rocker/ml-verse:${R_VERSION}-${OS}-cuda${CUDA_VERSION}" .

rm Dockerfile
ln -s "dockerfiles/Dockerfile_r-ver_${R_VERSION}-${OS}-cuda${CUDA_VERSION}-shiny" Dockerfile
docker build -t "rocker/shiny:${R_VERSION}-${OS}-cuda${CUDA_VERSION}" .
