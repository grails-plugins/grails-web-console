rm -rf target/release
mkdir -p target/release
cd target/release
git clone git@github.com:vsachinv/grails-console.git

cd grails-console
npm install
gulp grails4:release

cd grails4/plugin
./gradlew clean
./gradlew compileGroovy
./gradlew publishMavenJarPublicationToGitHubPackagesRepository
