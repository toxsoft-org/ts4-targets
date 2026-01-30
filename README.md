# ts4-targets
Built target libraries and plugins

1. install & build
 ./build.sh

2. clear git local repository
 ./build.sh clean

3. Build of a specific project for rcp, for example, skf-general:
cd ../skf-general
mvn clean install -Drcp

4. Build of a specific project for rap, for example, skf-general:
mvn clean install -Drap

5. Prepare for offline work (must have an internet connection):
mvn clean install -Drcp dependency:go-offline
mvn clean install -Drap dependency:go-offline

6. Offline build:
mvn -o clean install -Drcp
èëè
mvn -o clean install -Drap

7. Change plugin version, for example: ts4-uskat
cd ..\ts4-uskat 
mvn org.eclipse.tycho:tycho-versions-plugin:set-version -DnewVersion=1.0.0-SNAPSHOT -Dtycho.mode=maven
