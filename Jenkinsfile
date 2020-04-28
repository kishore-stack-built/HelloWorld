#!/usr/bin/env groovy
try {
	stage('Checkout') {
        node('master') {
            last_stage = env.STAGE_NAME
            cleanWs()
            sh "git config --global http.postBuffer 24288000 | true"
            sh "git config --global user.name 'kishore-stack-built'"
            sh "git config --global user.email 'e.kishore4022@gmail.com'"
            git credentialsId: '2d72c9448e27f2fe9ba60ef145a9776680374ee9',
            branch : '$GIT_BRANCH',
            url : "https://github.com/kishore-stack-built/HelloWorld.git";
        }
    }
	stage('Versioning & Tag Creation') {
        node('master') {
            last_stage = env.STAGE_NAME
            withCredentials([usernamePassword(credentialsId: 'git_cred', 
            passwordVariable: 'GIT_PASSWORD', usernameVariable: 'GIT_USERNAME')]) {
                def pre_version= readFile(file : 'version.txt')
				sh "echo Old Version: $pre_version"
				sh "chmod +x ${WORKSPACE}/version_gen.sh"
				new_version=sh ( 
					script: "${WORKSPACE}/version_gen.sh $pre_version",
					returnStdout: true
				  ).trim()
                sh "echo New Version: $new_version"
                writeFile(file: 'version.txt', text: new_version)
                sh "git add -f .";
                sh "git commit -m 'Jenkins Build'";
                sh "git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/kishore-stack-built/HelloWorld.git"
                sh "git tag -a $new_version -m 'Jenkins Tag Created - $new_version'"
                sh "git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/kishore-stack-built/HelloWorld.git --tags"
                def versionBuild = currentBuild.number
                currentBuild.displayName = "#${versionBuild} - ${new_version}"
            }
        }
    }
	stage('Maven Build & SonarQube Scanner') {
        node('master') {
            last_stage = env.STAGE_NAME
            dir("${WORKSPACE}/com.stackbuilt.web/") {
                withSonarQubeEnv('SonarQubeServer') {
					def pom = readMavenPom file: 'pom.xml'
					sh "mvn versions:set -DnewVersion=$new_version -f pom.xml"
                    sh "mvn clean verify -DgenerateBackupPoms=false sonar:sonar -Dsonar.host.url=http://192.168.0.112:9000 -Dsonar.projectName='${pom.artifactId}_$GIT_BRANCH' -Dsonar.projectVersion=$new_version -Dsonar.analysis.buildNumber=$new_version -Dsonar.login='035b95a77244fb9d5d1b62043404e54f7f2ac52c'"
                }
            }
        }
    }
	stage('Quality Gate Check'){
        node('master') {
            last_stage = env.STAGE_NAME
            sleep(10)
            timeout(time: 10, unit: 'MINUTES') {
               def qg = waitForQualityGate()
               print "Finished waiting"
               if (qg.status != 'OK') {
                   error "Pipeline aborted due to quality gate failure: ${qg.status}"
               }
            }
        }
    }
	stage('Nexus Publish'){
		node('master') {
			last_stage = env.STAGE_NAME
			echo 'Publish to Nexus Repository....'
			dir("${WORKSPACE}/com.stackbuilt.web.helloworld/") {
				// Read POM xml file using 'readMavenPom'
				pom = readMavenPom file: "pom.xml";
				// Find built artifact under Target folder
				filesByGlob = findFiles(glob: "target/*.${pom.packaging}");
				// Print some info from the artifact found
				echo "${filesByGlob[0].name} ${filesByGlob[0].path} ${filesByGlob[0].directory} ${filesByGlob[0].length}"
				// Extract the path from the file found
				artifactPath = filesByGlob[0].path;
				// Verify artifact name exist or not
				artifactExists = filesExists artifactPath;
				if(artifactExists) {
					echo "*** File: ${artifactPath}, group: ${pom.groupId}, artifact: ${pom.artifactId}, packaging: ${pom.packaging}, version ${pom.version}";
				}else {
					error "*** File: ${artifactPath}, could not be found";
				}
			}
		}
	}
}catch(err) {
    currentBuild.result = "FAILURE"
    throw err;
}