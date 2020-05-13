pipeline {
    agent {
        node {
            label 'master'
        }
    }

    stages {
        stage('terraform clone') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/EC2RDS']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: '7e261af1-1211-4b5a-9478-675cac127cce', url: 'https://github.com/GodsonSibreyan/Godsontf.git']]])
            }
        }
        stage('Success Message'){
            steps {
               script {
			      instance="${params.Env}"
			          if ("$instance" == "single"){
                            sh "rm -rf install.sh rds.tf"
                            sh "sed -i \"s/install.sh/single.sh/g\" /var/lib/jenkins/workspace/Django/ec2.tf"
                            sh 'echo "Everything is Perfect, Go Ahead for Singleserver!!!"'
                      }
					  else{
		                    sh 'echo "Everything is Perfect, Go Ahead for Multiserver!!!"'
		              }
                }
                  }
            }
        stage('Parameters'){
            steps {
                sh label: '', script: ''' sed -i \"s/user/$access_key/g\" /var/lib/jenkins/workspace/Django/variables.tf
sed -i \"s/password/$secret_key/g\" /var/lib/jenkins/workspace/Django/variables.tf
sed -i \"s/t2.micro/$instance_type/g\" /var/lib/jenkins/workspace/Django/variables.tf
sed -i \"s/10/$instance_size/g\" /var/lib/jenkins/workspace/Django/ec2.tf
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
                sleep 1020
            }
        } 
        stage("git checkout") {
	     steps {
		    checkout([$class: 'GitSCM', branches: [[name: '*/branchPy']], doGenerateSubmoduleConfigurations: false, extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: 'djangocodebase']], submoduleCfg: [], userRemoteConfigs: [[credentialsId: '7e261af1-1211-4b5a-9478-675cac127cce', url: 'https://github.com/GodsonSibreyan/Godsontf.git']]])
           }
        }
		
        stage('SonarQube analysis') {
	     steps {
	       script {
           scannerHome = tool 'sonarqube';
           withSonarQubeEnv('sonarqube') {
		   sh "${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=zippyops:django -Dsonar.projectName=django -Dsonar.projectVersion=1.0 -Dsonar.projectBaseDir=${WORKSPACE}/djangocodebase -Dsonar.sources=${WORKSPACE}/djangocodebase"
            }
	      }
		}
	    }
        stage("Sonarqube Quality Gate") {
	     steps {
	      script { 
            sleep(60)
            qg = waitForQualityGate() 
		    }
           }
        }
	    stage("Dependency Check") {
		 steps {
	      script {  
			dependencycheck additionalArguments: '', odcInstallation: 'Dependency'
			dependencyCheckPublisher pattern: ''
        }
        archiveArtifacts allowEmptyArchive: true, artifacts: '**/dependency-check-report.xml', onlyIfSuccessful: true
        }
        } 
	    stage('Application Deployment') {
          steps {
		    script {
			      instance="${params.Env}"
			          if ("$instance" == "single"){
                            sh label: '', script: '''pubIP=$(<publicip)
                            echo "$pubIP"
                            ssh -tt -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ec2-user@$pubIP /bin/bash << EOF
                            git clone -b branchPy https://github.com/GodsonSibreyan/Godsontf.git
                            sleep 5
                            sudo /bin/su - root
                            sleep 5
                            cd /home/ec2-user/Godsontf
                            mysql --defaults-extra-file=mysql zippyops < zippyops.sql
                            chmod 755 manage.py
                            python manage.py migrate
                            nohup ./manage.py runserver 0.0.0.0:8000 &
                            sleep 10
                            exit
                            sleep 5
                            exit
							EOF'''
                      }
					  else{
		                   sh label: '', script: '''pubIP=$(<publicip)
                           echo "$pubIP"
						   endpoint=$(<endpoint)
						   echo "$endpoint"
						   ssh -tt -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ec2-user@$pubIP /bin/bash << EOF
						   git clone -b branchPy https://github.com/GodsonSibreyan/Godsontf.git
						   sleep 5
						   sudo /bin/su - root
						   sleep 5
						   cd /home/ec2-user/Godsontf
                           sed -i \"s/localhost/$endpoint/g\" /home/ec2-user/Godsontf/python_webapp_django/settings.py
                           mysql --defaults-extra-file=mysql -h $endpoint --database zippyops < zippyops.sql
						   chmod 755 manage.py
                           python manage.py migrate
                           nohup ./manage.py runserver 0.0.0.0:8000 &
                           sleep 10
                           exit
                           sleep 5
                           exit
						   EOF
                           '''
		              }
                } 
            }
        }
	    stage('VAPT') {
            steps {
                 sh label: '', script: '''pubIP=$(<publicip)
                 echo "$pubIP"
                 ssh -tt root@192.168.5.14 << SSH_EOF
                 echo "open vas server"
                 nohup ./code16.py $pubIP &
                 sleep 5
                 exit
                 SSH_EOF 
                 '''
            }
        }
        stage('OWASP'){
            steps {
                   sh label: '', script: '''pubIP=$(<publicip)
                   echo "$pubIP"
                   mkdir -p $WORKSPACE/out
                   chmod 777 $WORKSPACE/out
                   rm -f $WORKSPACE/out/*.*
                   sudo docker run --rm --network=host -v ${WORKSPACE}/out:/zap/wrk/:rw -t docker.io/owasp/zap2docker-stable zap-baseline.py -t http://$pubIP:8000 -m 15 -d -r Django_Dev_ZAP_VULNERABILITY_REPORT_${BUILD_ID}.html -x Django_Dev_ZAP_VULNERABILITY_REPORT_${BUILD_ID}.xml || true
                   '''
                   archiveArtifacts artifacts: 'out/**/*'
		    }
        } 
        stage('linkChecker'){
            steps {
                   sh label: '', script: '''pubIP=$(<publicip)
                   echo "$pubIP"
                   date
                   sudo docker run --rm --network=host ktbartholomew/link-checker --concurrency 30 --threshold 0.05 http://$pubIP:8000 > $WORKSPACE/brokenlink_${BUILD_ID}.html || true
                   date
                   '''
                   archiveArtifacts artifacts: '**/brokenlink_${BUILD_ID}.html'
                   }
        }
        stage('SpeedTest') {
	      steps {
                   sh label: '', script: '''pubIP=$(<publicip)
                   echo "$pubIP"
		           cp -r /var/lib/jenkins/speedtest/budget.json  ${WORKSPACE}
                   sudo docker run --rm --network=host -v ${WORKSPACE}:/sitespeed.io sitespeedio/sitespeed.io http://$pubIP:8000 --outputFolder junitoutput --budget.configPath budget.json --budget.output junit -b chrome -n 1  || true
		  '''
		  archiveArtifacts artifacts: 'junitoutput/**/*'
		  }
	    }
        stage('Deployed') {
            steps {
                 sh label: '', script: '''rm -rf publicip endpoint
                 echo "Deployed"
                 '''
            }
        }
    }
	post {
        always {
        publishHTML target: [
              allowMissing: false,
              alwaysLinkToLastBuild: true,
              keepAll: true,
              reportDir: '/var/lib/jenkins/jobs/${JOB_NAME}/builds/${BUILD_ID}/archive/junitoutput',
              reportFiles: 'index.html',
              reportName: 'Dev_speedtest'
			  ]
        publishHTML target: [
              allowMissing: false,
              alwaysLinkToLastBuild: true,
              keepAll: true,
              reportDir: '/var/lib/jenkins/jobs/${JOB_NAME}/builds/${BUILD_ID}/archive',
              reportFiles: 'brokenlink_${BUILD_ID}.html',
              reportName: 'Dev_linkcheck'
              ]
		publishHTML target: [
              allowMissing: false,
              alwaysLinkToLastBuild: true,
              keepAll: true,
              reportDir: '/var/lib/jenkins/jobs/${JOB_NAME}/builds/${BUILD_ID}/archive/out',
              reportFiles: 'Django_Dev_ZAP_VULNERABILITY_REPORT_${BUILD_ID}.html',
              reportName: 'Dev_owasp'
              ]
            }
        }
    }
	
	
	
