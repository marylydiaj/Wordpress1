pipeline {
    agent {
        node {
            label 'master'
        }
    }

    stages {
        stage('terraform clone') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: '7e261af1-1211-4b5a-9478-675cac127cce', url: 'https://github.com/GodsonSibreyan/Godsontf.git']]])
            }
        }
        stage('Parameters'){
            steps {
                sh label: '', script: ''' sed -i \"s/user/$access_key/g\" /var/lib/jenkins/workspace/terragods/variables.tf
sed -i \"s/password/$secret_key/g\" /var/lib/jenkins/workspace/terragods/variables.tf
sed -i \"s/t2.micro/$instance_type/g\" /var/lib/jenkins/workspace/terragods/variables.tf
sed -i \"s/10/$instance_size/g\" /var/lib/jenkins/workspace/terragods/ec2.tf
sed -i \"s/us-east-2/$instance_region/g\" /var/lib/jenkins/workspace/terragods/variables.tf
sed -i \"s/us-east-2a/$availability_zone/g\" /var/lib/jenkins/workspace/terragods/variables.tf
sed -i \"s/gods/$key/g\" /var/lib/jenkins/workspace/terragods/variables.tf
sed -i \"s/ami-0f7919c33c90f5b58/$Image/g\" /var/lib/jenkins/workspace/terragods/variables.tf
'''
                  }
            }
            
        stage('terraform init') {
            steps {
                sh 'terraform init'
            }
        }
        stage('terraform plan') {
            steps {
                sh 'terraform plan'
            }
        }
        stage('terraform apply') {
            steps {
                sh 'terraform apply -auto-approve'
                sleep 150
            }
        }
         stage('Application Deployment') {
            steps {
                sh label: '', script: '''pubIP=$(<publicip)
                echo "$pubIP"
                ssh -tt -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ec2-user@$pubIP /bin/bash << EOF
                git clone -b branchPy https://github.com/GodsonSibreyan/Godsontf.git
                cd Godsontf/
                chmod 755 manage.py
                python manage.py migrate
                nohup ./manage.py runserver 0.0.0.0:8000 &
                sleep 120
                exit 
                EOF
                '''
            }
        }
       
    }
}
