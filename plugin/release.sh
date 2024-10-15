rm -rf target/release
mkdir -p target/release
cd target/release
git clone git@github.com:gpc/grails-web-console.git

cd grails-web-console
npm install
gulp grails:release

cd plugin
./gradlew clean
./gradlew compileGroovy
./gradlew publishMavenJarPublicationToGitHubPackagesRepository
