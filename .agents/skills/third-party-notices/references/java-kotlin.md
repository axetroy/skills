# Java / Kotlin (Maven, Gradle)

## Signal files

- Maven: `pom.xml` (parent POMs for multi-module), `mvnw`
- Gradle: `build.gradle`, `build.gradle.kts`, `gradle/wrapper/`

## 1. Preferred tools

Maven (license-maven-plugin):

```bash
mvn license:third-party-report
# output: target/site/THIRD-PARTY.txt (plus HTML/XML)
```

Multi-module aggregate:

```bash
mvn license:aggregate-third-party-report
```

Gradle (license-report plugin) — declare the plugin in `build.gradle`:

```groovy
plugins { id 'com.github.jk1.license' version '0.16.1' }
```

then:

```bash
./gradlew generateLicenseReport
# output: build/reports/license/ (license-dependency.html + .csv)
```

Dependency trees without licenses:

```bash
mvn dependency:tree
./gradlew dependencies
```

## 2. Fallback: parse the dependency tree

- Maven: `mvn dependency:tree -DoutputFile=deps.txt`; resolve each `g:a:v` via:
  - the POM: `https://repo1.maven.org/maven2/<group path>/<artifact>/<version>/<artifact>-<version>.pom` → `<licenses><license>` sections
  - Maven Central search API: `https://search.maven.org/solrsearch/select?q=g:"<group>" AND a:"<artifact>" AND v:"<version>"&rows=20&wt=json` → `response.docs[].license`
- Gradle: read `gradle.lockfile` when dependency locking is enabled, or the resolution result from `dependencies`.

## 3. License texts

1. `mvn license:third-party-report` output includes license text.
2. From the jar's `META-INF/` (LICENSE files) — download `.../<artifact>-<version>.jar`.
3. From the POM `<licenses>` section (may include a `<url>` to the license text).
4. SPDX canonical text: `https://spdx.org/licenses/<SPDX_ID>.json`.

## 4. Edge cases

- Multi-module builds: aggregate so each module is counted once.
- Scopes: skip `test` / `provided` in Maven and `testImplementation` in Gradle when not shipped.
- BOMs / `<dependencyManagement>` pin versions but are not shipped — exclude unless actually used.
- Snapshots: record the exact snapshot version.
