# ts4-targets
Built target libraries and plugins

1. Build targets for rcp: 
mvn clean install -Drcp

2. Build targets for rap: 
mvn clean install -Drap

3. Prepare for offline work (must have an internet connection):
mvn clean install -Drcp dependency:go-offline
mvn clean install -Drap dependency:go-offline

4. Offline build:
mvn -o clean install -Drcp
или
mvn -o clean install -Drap

4. Change plugin version, for example: ts4-uskat
cd ..\ts4-uskat 
mvn org.eclipse.tycho:tycho-versions-plugin:set-version -DnewVersion=1.0.0-SNAPSHOT -Dtycho.mode=maven
