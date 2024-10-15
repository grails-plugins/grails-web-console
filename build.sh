npm install

npx gulp grailsRelease

cd plugin
./gradlew clean
./gradlew jar

echo
realpath build/libs/grails-console-*.jar
