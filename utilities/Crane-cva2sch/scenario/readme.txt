Crane's Schematron implementation of OASIS CVA files
====================================================

To engage this scenario, copy the following JAR files into the 
utility directory:

  From xjparse:      xjparse.jar
  From xerces:       resolver.jar, xercesImpl.jar
  From saxon 6.5.5:  saxon.jar

The following files are utility files for xjparse and are not part
of the scenario and can be deleted if you are not using xjparse:

  catalog.xml
  CatalogManager.properties

The scenario is invoked using:

  Windows command prompt:  test-all.bat
  Shell command prompt:    sh test-all.sh

===============================================
