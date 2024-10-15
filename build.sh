npm install

npx gulp grailsRelease

cd plugin
./gradlew clean
./gradlew build

echo
realpath build/libs/grails-web-console-*.jar
