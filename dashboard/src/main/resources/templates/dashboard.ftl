<html lang="en-US">
  <head>
    <title>Google Cloud Platform Java Open Source Dependency Dashboard</title>
    
    <link rel="stylesheet" type="text/css" href="dashboard.css" />
  </head>
  <body>
    <h1>Google Cloud Platform Java Dependency Dashboard</h1>
    <hr />
    
    <section class="statistics">
      <div class="container">
        <div class="statistic-item statistic-item-green">
          <h2 class="artifact-count">${table?size}</h2>
          <span class="desc">Total Artifacts Checked</span>
        </div>
        <div class="statistic-item statistic-item-red">
          <h2 class="artifact-count"><@countFailures name="Static Linkage Errors"/></h2>
          <span class="desc">Have Static Linkage Errors</span>
        </div>
        <div class="statistic-item statistic-item-yellow">
          <h2 class="artifact-count"><@countFailures name="Upper Bounds"/></h2>
          <span class="desc">Have Upper Bounds Errors</span>
        </div>
        <div class="statistic-item statistic-item-orange">
          <h2 class="artifact-count"><@countFailures name="Global Upper Bounds"/></h2>
          <span class="desc">Have Global Upper Bounds Errors</span>
        </div>
        <div class="statistic-item statistic-item-blue">
          <h2 class="artifact-count"><@countFailures name="Dependency Convergence"/></h2>
          <span class="desc">Fail to Converge</span>
        </div>
      </div>
    </section>
    
    <#macro countFailures name>
      <#assign total = 0>
      <#list table as row>    
        <#if row.getResult(name)?? >
          <#assign failure_count = row.getFailureCount(name)>
          <#if failure_count gt 0 >
            <#assign total = total + 1>
          </#if>
        <#else>
          <#-- Null means there's an exception and test couldn't run -->
          <#assign total = total + 1>
        </#if>
      </#list>
      ${total}
    </#macro>
    
    <h2>Artifact Details</h2>
    
    <#macro testResult row name>
      <#if row.getResult(name)?? ><#-- checking isNotNull() -->
        <#-- When it's not null, the test ran. It's either PASS or FAIL -->
        <#assign test_label = row.getResult(name)?then('PASS', 'FAIL')>
        <#assign failure_count = row.getFailureCount(name)>
      <#else>
        <#-- Null means there's an exception and test couldn't run -->
        <#assign test_label = "UNAVAILABLE">
      </#if>
      <td class='${test_label}' title="${row.getExceptionMessage()!""}">
        <#if row.getResult(name)?? >
          <#assign page_anchor =  name?replace(" ", "-")?lower_case />
          <a href="${row.getCoordinates()?replace(":", "_")}.html#${page_anchor}">
            <#if failure_count == 1>1 FAILURE
            <#elseif failure_count gt 1>${failure_count} FAILURES
            <#else>PASS
            </#if>
          </a>
        <#else>UNAVAILABLE
        </#if>
      </td>
    </#macro>
    
    <table class="dependency-dashboard">
      <tr>
        <th>Artifact</th>
        <th title=
                "Static linkage check result for the artifact and transitive dependencies. PASS means all symbol references have valid referents.">
          Static Linkage Check</th>
        <th title=
          "For each transitive dependency the library pulls in, the highest version found anywhere in the dependency tree is picked.">
          Upper Bounds</th>
        <th title=
          "For each transitive dependency the library pulls in, the highest version found anywhere in the union of the BOM's dependency trees is picked.">
          Global Upper Bounds</th>
        <th title=
                "There is exactly one version of each dependency in the library's transitive dependency tree. That is, two artifacts with the same group ID and artifact ID but different versions do not appear in the tree. No dependency mediation is necessary.">
          Dependency Convergence</th>
      </tr>
      <#list table as row>
        <#assign report_url = row.getCoordinates()?replace(":", "_") + '.html' />
        <tr>
          <td class="artifact-name"><a href='${report_url}'>${row.getCoordinates()}</a></td>
          <#-- The name key should match TEST_NAME_XXXX variables -->
          <@testResult row=row name="Static Linkage Errors"/>
          <@testResult row=row name="Upper Bounds"/>
          <@testResult row=row name="Global Upper Bounds"/>
          <@testResult row=row name="Dependency Convergence"/>
        </tr>
      </#list>
    </table>
    
    <hr />

    <h2>Static Linkage Errors</h2>

    <#list jarLinkageReports as jarLinkageReport>
      <#if jarLinkageReport.getTotalErrorCount() gt 0>
        <pre id="static-linkage-errors">${jarLinkageReport?html}</pre>

        <p class="static-linkage-check-dependency-paths">
          Following paths to the jar file from BOM are found in the dependency tree.
        </p>
        <ul class="static-linkage-check-dependency-paths">
          <#list jarToDependencyPaths.get(jarLinkageReport.getJarPath()) as dependencyPath >
            <li>${dependencyPath}</li>
          </#list>
        </ul>

      </#if>
    </#list>

    <hr />      
      
    <h2>Recommended Versions</h2>
      
    <p>These are the most recent versions of dependencies used by any of the covered artifacts.</p> 
      
    <ul id="recommended">
      <#list latestArtifacts as artifact, version>
        <li>${artifact}:${version}</li>
      </#list>
    </ul>
 
    <hr />
      
    <h2>Pre 1.0 Versions</h2>
      
    <p>
      These are dependencies found in the GCP orbit which have not yet reached 1.0.
      No 1.0 or later library should depend on them.
      If the libraries are stable, advance them to 1.0.
      Otherwise replace the dependency with something else.
    </p> 
    
    <#assign unstableCount = 0>
    <ul id="unstable">
      <#list latestArtifacts as artifact, version>
        <#if version[0] == '0'>
          <#assign unstableCount++>
          <li>${artifact}:${version}</li>
        </#if>
      </#list>
    </ul>
     
    <#if unstableCount == 0>
      <p id="stable-notice">All versions are 1.0 or later.</p> 
    </#if>
    
     
    <hr />
    <p id='updated'>Last generated at ${lastUpdated}</p>
  </body>
</html>