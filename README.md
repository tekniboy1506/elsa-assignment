# This is the document for setting up this Assignment, made by Thanh Phan by forking the Hackathon Starter Repo
### Note: 
  - Due to the lack of my JS coding skills, so I'm sorry that I wouldn't be able to achieve the Bonus point on Step 2. Also I wouldn't be able to automate creating the CI/CD pipeline in Jenkins, instead this setup   will only start up the Jenkins and has the Jenkinsfile available in `setups/jenkins` folder for you to set this up.
  - Also I found out that this app builds the frontend and the backend together which I don't think they can be separated into 2 separate apps, so I'll only adjust the app's Dockerfile to be more appropriate.
  - This setup has been tested on Ubuntu > 20.04 lts and CentOS 9, there is also a possibility to set this up on MacOS but it may require some manual adjustments.

## Contents:
###  Init setup: 
  - Provided by the `setups/setup.sh` script. It will install some necessary packages, install Nodejs 20, Docker, Minikube, Kubectl, Nginx and Jenkins. It will base on the OS and the Architecture to acquire the appropriate setup for the environment.
### Minikube init: 
  - Provided by the `setups/minikube_init.sh`. It will init the `Minikube Cluster` with the `Nginx Ingress` addons and `MongoDB` installed and the local Docker Registry for managing Docker images.
  - This script is triggered by default in the `setup.sh` script
### Docker image build: 
  - Provided by the `setups/build.sh`. It will build the app's Docker image and push it into the local Docker Registry.
  - Run script after running the Minikube init script.
### Kubernetes deploy: 
  - Provided by the `setups/deploy.sh`. It will deploy the app into the Minikube cluster, deployment manifests are available in the `k8s` folder.
  - After running the `build.sh` script, you can run this script.
  - Inside the `k8s` folder, there're also the configmap and secrets manifest which provide environment variables into the app
### Jenkins: 
  - There's a docker-compose file and a Jenkinsfile in the `setups/jenkins` folder to boot up the Jenkins. The `setup.sh` script's final stage will bring up the Jenkins and it will be accessible at the Host IP's port `8080`.
### Nginx:
  - I brought Nginx into this setup to make the app available publicly by setting up a reverse proxy to the app inside the Minikube cluster.
  - This setup will be performed when running the `setup.sh`.
  - After run the `deploy.sh` script, the app will be accessible via the Host IP's port `80`.

### Troubleshooting guide:
  - If you run into a `permission denied` error when trying to run any docker command (most probably when you run the `setups/build.sh` script), You can try logging out and logging in again to the shell to re-init the session, or you can run the script like this: `sudo su $USER -c ./setups/build.sh`.
  - If you have issue when pushing or pulling the app's image to the local Docker Repo, kindly check again if the Minikube's network range is `192.168.49.0`(this is the default network range when you start a Minikube cluster without any custom network setup) by running `minikube ip` or `docker inspect minikube`. If it's not the range, kindly change the Docker repo's url respectively (e.g if the network range is 172.16.0.0/24, the Docker repo's url should be 172.16.0.1:5000 instead).
  


