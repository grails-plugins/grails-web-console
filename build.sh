npm install

# for Grails 3

npx gulp grails3Release

cd grails3/plugin
./gradlew clean
./gradlew jar

echo
realpath build/libs/grails-console-*.jar

# for Grails 4

npx gulp grails4Release

cd grails4/plugin
./gradlew clean
./gradlew jar

echo
realpath build/libs/grails-console-*.jar