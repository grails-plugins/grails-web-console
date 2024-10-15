rm -rf target/release
mkdir -p target/release
cd target/release
git clone git@github.com:gpc/grails-console.git

cd grails-console
npm install
gulp grails:release

cd plugin
./gradlew clean
./gradlew compileGroovy
./gradlew publishMavenJarPublicationToGitHubPackagesRepository
