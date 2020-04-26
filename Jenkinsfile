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
				def new_version="";
                sh "version_gen.sh $pre_version">new_version
                sh "echo New Version: $new_version"
                writeFile(file: 'version.conf', text: new_version)
                sh "git add -f .";
                sh "git commit -m 'Jenkins Build'";
                sh "git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/kishore-stack-built/sonar-test.git"
                sh "git tag -a $new_version -m 'Jenkins Tag Created - $new_version'"
                sh "git push https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/kishore-stack-built/sonar-test.git --tags"
                def versionBuild = currentBuild.number
                currentBuild.displayName = "#${versionBuild} - ${new_version}"
            }
        }
    }
}catch(err) {
    currentBuild.result = "FAILURE"
    throw err;
}