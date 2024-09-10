rm -rf target/release
mkdir -p target/release
cd target/release
git clone git@github.com:vsachinv/grails-console.git

cd grails-console
npm install
gulp grails5:release

cd grails5/plugin
./gradlew clean
./gradlew compileGroovy
./gradlew publishMavenJarPublicationToGitHubPackagesRepository
