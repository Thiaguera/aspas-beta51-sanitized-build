# Diagnóstico da compilação de teste

Arquivo automático sem fontes restaurados, variáveis de ambiente ou credenciais.

- Commit analisado: 31796f275423320f1c019553b87d7dfcb26a4aec
- Execução: https://github.com/Thiaguera/aspas-beta51-sanitized-build/actions/runs/41584885327
- JDK: success
- Plataforma Android: fornecida pela imagem do runner; não é instalada por sdkmanager.
- Restauração: success
- Gradle 8.9: success
- assembleDebug: success

## restore.log
```text
5 imagens PNG restauradas localmente.
Fontes completos restaurados. Leia README.md antes de executar o aplicativo.
```

## gradle-download.log
```text
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0100   169  100   169    0     0   3531      0 --:--:-- --:--:-- --:--:--  3595
  0     0    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
100  129M  100  129M    0     0   197M      0 --:--:-- --:--:-- --:--:--  197M
/tmp/gradle.zip: OK
```

## gradle-build.log
```text

Welcome to Gradle 8.9!

Here are the highlights of this release:
 - Enhanced Error and Warning Messages
 - IDE Integration Improvements
 - Daemon JVM Information

For more details see https://docs.gradle.org/8.9/release-notes.html

To honour the JVM settings for this build a single-use Daemon process will be forked. For more on this, please refer to https://docs.gradle.org/8.9/userguide/gradle_daemon.html#sec:disabling_the_daemon in the Gradle documentation.
Daemon will be stopped at the end of the build 
> Task :app:preBuild UP-TO-DATE
> Task :app:preDebugBuild UP-TO-DATE
> Task :app:mergeDebugNativeDebugMetadata NO-SOURCE
> Task :app:javaPreCompileDebug
> Task :app:checkDebugAarMetadata
> Task :app:generateDebugResValues
> Task :app:mapDebugSourceSetPaths
> Task :app:generateDebugResources
> Task :app:mergeDebugResources
> Task :app:packageDebugResources
> Task :app:parseDebugLocalResources
> Task :app:createDebugCompatibleScreenManifests
> Task :app:extractDeepLinksDebug
> Task :app:processDebugMainManifest
> Task :app:processDebugManifest
> Task :app:processDebugManifestForPackage
> Task :app:processDebugResources

> Task :app:compileDebugJavaWithJavac
Note: /home/runner/work/aspas-beta51-sanitized-build/aspas-beta51-sanitized-build/app/src/main/java/br/com/aspas/contingencia/MainActivity.java uses or overrides a deprecated API.
Note: Recompile with -Xlint:deprecation for details.

> Task :app:mergeDebugShaders
> Task :app:compileDebugShaders NO-SOURCE
> Task :app:generateDebugAssets UP-TO-DATE
> Task :app:mergeDebugAssets
> Task :app:compressDebugAssets
> Task :app:processDebugJavaRes NO-SOURCE
> Task :app:mergeDebugJavaResource
> Task :app:checkDebugDuplicateClasses
> Task :app:desugarDebugFileDependencies
> Task :app:mergeExtDexDebug
> Task :app:mergeLibDexDebug
> Task :app:dexBuilderDebug
> Task :app:mergeProjectDexDebug
> Task :app:mergeDebugJniLibFolders
> Task :app:mergeDebugNativeLibs NO-SOURCE
> Task :app:stripDebugDebugSymbols NO-SOURCE
> Task :app:validateSigningDebug
> Task :app:writeDebugAppMetadata
> Task :app:writeDebugSigningConfigVersions
> Task :app:packageDebug
> Task :app:createDebugApkListingFileRedirect
> Task :app:assembleDebug

BUILD SUCCESSFUL in 48s
31 actionable tasks: 31 executed
```
