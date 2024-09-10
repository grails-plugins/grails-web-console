rm -rf target/release
mkdir -p target/release
cd target/release
git clone git@github.com:vsachinv/grails-console.git

cd grails-console
npm install
gulp grails6:release

cd grails6/plugin
./gradlew clean
./gradlew compileGroovy
./gradlew publishMavenJarPublicationToGitHubPackagesRepository
