@ECHO OFF

SET cur_dir=%CD%

SET base_dir=%cur_dir%\..\..
SET groovy_dir=%base_dir%\lib\groovy
SET generator_dir=%base_dir%\tools\codegenerator
SET bin_dir=%cur_dir%\..\BuildDependencies\bin

rem go into xbmc/interfaces/python
cd %1\..\python

SET python_dir=%CD%
SET python_generated_dir=%python_dir%\generated
SET doxygen_dir=%python_generated_dir%\doxygenxml
SET swig_dir=%python_dir%\..\swig

rem make sure all necessary directories exist and delete any old generated files
IF NOT EXIST %python_generated_dir% md %python_generated_dir%
IF EXIST %python_generated_dir%\%2.xml del %python_generated_dir%\%2.xml
IF EXIST %python_generated_dir%\%2.cpp del %python_generated_dir%\%2.cpp
IF NOT EXIST %doxygen_dir% md %doxygen_dir%

rem run doxygen
%bin_dir%\doxygen\doxygen.exe > NUL 2>&1

rem run swig to generate the XML used by groovy to generate the python bindings
%bin_dir%\swig\swig.exe -w401 -c++ -outdir %python_generated_dir% -o %python_generated_dir%\%2.xml -xml -I"%base_Dir%\xbmc" -xmllang python %swig_dir%\%2.i
rem run groovy to generate the python bindings
java.exe -cp "%groovy_dir%\groovy-all-1.8.4.jar;%groovy_dir%\commons-lang-2.6.jar;%generator_dir%;%python_dir%" groovy.ui.GroovyMain %generator_dir%\Generator.groovy %python_generated_dir%\%2.xml %python_dir%\PythonSwig.cpp.template  %python_generated_dir%\%2.cpp %doxygen_dir%

rem go back to the initial directory
cd %cur_dir%